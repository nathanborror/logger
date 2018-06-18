import UIKit
import LoggerKit

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

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChange),
                                               name: .UIKeyboardDidChangeFrame, object: nil)

        Kit.observe(self, selector: #selector(stateChange))
    }

    override func viewDidAppear(_ animated: Bool) {
        composer.textView.becomeFirstResponder()
        super.viewDidAppear(animated)
    }

    @objc func stateChange() {
        let state = Kit.state
        let priorEntries = model.entries
        if model.applyEntries(state) {
            if priorEntries.count > 0 {
                tableView.applyDiff(prior: priorEntries, section: 0, animation: .top) {
                    return model.entries
                }
            } else {
                tableView.reloadData()
                if model.entries.count > 0 {
                    tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                }
            }
        }
        if model.applySearch(state) {
            tableView.reloadData()
        }
        _ = model.applyUndo(state)
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        composer.bottomSafeAreaInset = view.safeAreaInsets.bottom
    }

    // MARK: - Handlers

    @objc func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .began else { return }
        let point = recognizer.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        guard let cell = tableView.cellForRow(at: indexPath) as? EntryCell else { return }
        let entry = model.entries[indexPath.row]
        let cellFrame = cell.convert(cell.contentView.frame, to: view)

        let vc = MenuVC(entry: entry)
        vc.transitioningDelegate = vc
        vc.preferredContentSize = CGSize(width: 240, height: 54)
        vc.sourceRect = cellFrame
        vc.modalPresentationStyle = .custom
        if entry.image != nil {
            vc.searchButton.isHidden = true
            vc.wikiButton.isHidden = true
            vc.preferredContentSize = CGSize(width: 80, height: 54)
        }
        presentOverKeyboard(vc, animated: true, completion: nil)
    }

    func handleHashtag(_ tag: String) {
        composer.query = tag
        try! Kit.entrySearch(tag)
    }

    func handleLink(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func handlePhoto(_ image: UIImage) {
        let vc = UINavigationController(rootViewController: EntryPhotoVC(image: image))
        present(vc, animated: true, completion: nil)
    }

    // MARK: - Export

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        guard model.isUndoAvailable else {
            handleExportOptions()
            return
        }
        let vc = UIAlertController(title: "Undo Delete", message: nil, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        vc.addAction(UIAlertAction(title: "Undo", style: .default, handler: { _ in
            try! Kit.undoEntryDelete()
        }))
        present(vc, animated: true, completion: nil)
    }

    func handleExportOptions() {
        let vc = UIActivityViewController(activityItems: [FileManager.database], applicationActivities: nil)
        present(vc, animated: true, completion: nil)
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

    func composerDidBeginEditing(_ composer: Composer) {
        composer.bottomSafeAreaInset = 0
    }

    func composerDidEndEditing(_ composer: Composer) {
        composer.bottomSafeAreaInset = view.safeAreaInsets.bottom
    }

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
    var isUndoAvailable = false

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

    mutating func applyUndo(_ state: State) -> Bool {
        let stateIsUndoAvailable = state.undo.deleted.count > 0
        guard isUndoAvailable != stateIsUndoAvailable else { return false }
        isUndoAvailable = stateIsUndoAvailable
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
