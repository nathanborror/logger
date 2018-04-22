import UIKit
import LoggerKit
import SafariServices

class EntriesVC: UINavigationController {

    convenience init() {
        self.init(rootViewController: EntriesTableVC())
        navigationBar.isHidden = true
    }
}

class EntriesTableVC: UIViewController {

    private var model = EntriesModel()
    private var tableView = UITableView()
    private var composer = Composer()

    override var inputAccessoryView: UIView? {
        return composer
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        composer.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EntryCell.self, forCellReuseIdentifier: "EntryCell")
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.backgroundColor = .background
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])

        // Provides secondary actions for entries
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        tableView.addGestureRecognizer(longPress)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChange), name: .UIKeyboardDidChangeFrame, object: nil)

        Kit.observe(self, selector: #selector(stateChange))
    }

    @objc func stateChange() {
        let state = Kit.state
        let priorEntries = model.entries
        if model.applyEntries(state) {
            guard priorEntries.count > 0 else {
                tableView.reloadData()
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                return
            }
            tableView.applyDiff(prior: priorEntries, section: 0, animation: .top) {
                return model.entries
            }
        }
        if model.applySearch(state) {
            tableView.reloadData()
        }
    }

    // MARK: - Handlers

    @objc func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        let entry = model.entries[indexPath.row]
        showActions(for: entry)
    }

    func handleHashtag(_ tag: String) {
        composer.query = tag
        try! Kit.entrySearch(tag)
    }

    func handleLink(_ url: URL) {
        let controller = SFSafariViewController(url: url)
        present(controller, animated: true, completion: nil)
    }

    func handlePhoto(_ image: UIImage) {
        let controller = UINavigationController(rootViewController: EntryPhotoVC(image: image))
        present(controller, animated: true, completion: nil)
    }

    func showActions(for entry: Entry) {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        vc.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            try! Kit.entryDelete(entry: entry)
        })
        vc.addAction(UIAlertAction(title: "Google", style: .default) { _ in
            let cleaned = entry.text.replace(regex: "#(\\w+\\s?)", with: "")
            let query = cleaned.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let url = URL(string: "https://google.com/search?q=\(query)")!
            let controller = SFSafariViewController(url: url)
            self.present(controller, animated: true, completion: nil)
        })
        present(vc, animated: true, completion: nil)
    }

    // MARK: - Export

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }

        let dir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let file = dir.appendingPathComponent("data.logger")

        let controller = UIActivityViewController(activityItems: [file], applicationActivities: nil)
        present(controller, animated: true, completion: nil)
    }

    // MARK: - Keyboard

    @objc func keyboardDidChange(notification: Notification) {
        guard let endFrameValue = notification.keyboardFrameEnd else { return }
        guard let animationDuration = notification.keyboardAnimationDuration else { return }
        guard let animationOptions = notification.keyboardAnimationOptions else { return }

        let keyboardSize = endFrameValue.size
        let contentInsets = UIEdgeInsets(top: keyboardSize.height - view.safeAreaInsets.bottom, left: 0, bottom: 0, right: 0)

        var contentOffset = tableView.contentOffset
        contentOffset.y = -contentInsets.top

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: {
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
            self.tableView.contentOffset = contentOffset
        }, completion: nil)
    }
}

extension EntriesTableVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = model.entries[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell", for: indexPath) as! EntryCell
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        cell.configure(with: entry)
        cell.onHashtagTap = { [weak self] tag in self?.handleHashtag(tag) }
        cell.onLinkTap = { [weak self] url in self?.handleLink(url) }
        cell.onEntryPhotoTap = { [weak self] image in self?.handlePhoto(image) }
        return cell
    }
}

extension EntriesTableVC: ComposerDelegate {

    func composerDidSubmit(_ composer: Composer) {
        guard let text = composer.text else { return }
        try! Kit.entryCreate(text: text)
        composer.reload()
    }

    func composerSearchDidChange(_ composer: Composer) {
        try! Kit.entrySearch(composer.query)
    }

    func composerPhotoPickerShouldShow(_ composer: Composer) {
        composer.textView.resignFirstResponder()
        let vc = UIImagePickerController()
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
}

extension EntriesTableVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let imageURL = info[UIImagePickerControllerImageURL] as? URL else { return }
        try! Kit.entryCreate(url: imageURL)
        picker.dismiss(animated: true, completion: nil)
    }
}

struct EntriesModel {

    var entries: [Entry] = []
    var matches: [Int] = []

    mutating func applyEntries(_ state: State) -> Bool {
        let stateEntries = Array(state.entries.values).sorted { $0.created < $1.created }
        guard entries != stateEntries else { return false }
        self.entries = filter(state.entries, ids: matches)
        return true
    }

    mutating func applySearch(_ state: State) -> Bool {
        let stateMatches = state.search.results
        guard matches != stateMatches else { return false }
        self.matches = stateMatches
        self.entries = filter(state.entries, ids: matches)
        return true
    }

    mutating func filter(_ entries: [Int: Entry], ids: [Int]) -> [Entry] {
        if ids.count > 0 {
            return ids.map { entries[$0] }.compactMap { $0 }
        } else {
            return Array(entries.values).sorted { $0.created > $1.created }
        }
    }
}
