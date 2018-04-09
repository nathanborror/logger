import UIKit

class EntryPhotoVC: UIViewController {

    private let scrollView = UIScrollView()
    private let imageView = UIImageView()

    private var imageViewTopConstraint: NSLayoutConstraint!
    private var imageViewBottomConstraint: NSLayoutConstraint!
    private var imageViewLeadingConstraint: NSLayoutConstraint!
    private var imageViewTrailingConstraint: NSLayoutConstraint!

    convenience init(image: UIImage) {
        self.init(nibName: nil, bundle: nil)
        imageView.image = image
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white

        imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(imageView)

        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        imageViewTopConstraint = imageView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        imageViewBottomConstraint = imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        imageViewLeadingConstraint = imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
        imageViewTrailingConstraint = imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            imageViewTopConstraint,
            imageViewBottomConstraint,
            imageViewLeadingConstraint,
            imageViewTrailingConstraint,
        ])

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)

        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
        navigationItem.setRightBarButton(done, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setZoomScale()
    }

    private func setZoomScale() {
        let widthScale = scrollView.frame.size.width / imageView.bounds.width
        let heightScale = scrollView.frame.size.height / imageView.bounds.height
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.zoomScale = scrollView.minimumZoomScale
    }

    @objc func handleDone() {
        dismiss(animated: true, completion: nil)
    }

    @objc func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let position = recognizer.location(in: scrollView)
            let rect = zoomRect(for: position)
            scrollView.zoom(to: rect, animated: true)
        }
    }

    private func zoomRect(for position: CGPoint) -> CGRect {
        let width  = imageView.frame.width
        let height = imageView.frame.height

        let center = imageView.convert(position, from: scrollView)
        let centerX = center.x - (width / 2)
        let centerY = center.y - (height / 2)

        return CGRect(x: centerX, y: centerY, width: width, height: height)
    }
}

extension EntryPhotoVC: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let yOffset = max(0, (scrollView.bounds.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset

        let xOffset = max(0, (scrollView.bounds.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset

        scrollView.layoutIfNeeded()
    }
}
