import UIKit

class WelcomeVC: UIViewController {

    let logoView = UIImageView()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: 0x000000)
        view.clipsToBounds = true

        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.bounds.width / 2, y: view.bounds.height + 100)
        emitter.emitterShape = kCAEmitterLayerLine
        emitter.emitterSize = CGSize(width: view.bounds.width, height: 50)
        emitter.emitterCells = generateEmitterCells()
        view.layer.addSublayer(emitter)

        logoView.image = UIImage(named: "Logo")!.withRenderingMode(.alwaysTemplate)
        logoView.tintColor = .white
        view.addSubview(logoView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let logoSize = CGSize(width: 100, height: 100)
        let logoOrigin = CGPoint(x: (view.bounds.width / 2) - (logoSize.width / 2), y: 150)
        logoView.frame = CGRect(origin: logoOrigin, size: logoSize)
    }

    private func generateEmitterCells() -> [CAEmitterCell] {
        var cells = [CAEmitterCell]()
        for i in 0..<3 {
            let cell = CAEmitterCell()
            cell.birthRate = 0.3
            cell.lifetime = 60
            cell.lifetimeRange = 0
            cell.velocity = -CGFloat(random(upper: 50, lower: 20))
            cell.velocityRange = 0
            cell.emissionLongitude = CGFloat.pi
            cell.emissionRange = CGFloat(random(upper: 4, lower: 2)) / 10
            cell.color = nextColor(i)
            cell.contents = nextImage(i)
            cell.scaleRange = 0.25
            cell.scale = 0.15
            cells.append(cell)
        }
        return cells
    }

    // MARK: - Color

    func nextColor(_ i: Int) -> CGColor {
        return colors[i % colors.count].cgColor
    }

    private let colors: [UIColor] = [
        //        UIColor(hex: 0x3A536A), UIColor(hex: 0x99A5B1), UIColor(hex: 0xFFFFFF),
        UIColor(hex: 0xFFFFFF).withAlphaComponent(0.04),
        UIColor(hex: 0xFFFFFF).withAlphaComponent(0.08),
        UIColor(hex: 0xFFFFFF).withAlphaComponent(0.12),
        ]

    // MARK: - Image

    func nextImage(_ i: Int) -> CGImage {
        return images[i % images.count].cgImage!
    }

    private let images: [UIImage] = [
        UIImage(named: "Oval")!
    ]

    // MARK: - Random

    func random(upper: UInt32, lower: UInt32) -> UInt32 {
        return arc4random_uniform(upper - lower) + lower
    }
}
