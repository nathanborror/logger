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
    private var initialSafeAreaInsets: UIEdgeInsets = .zero

    override var inputAccessoryView: UIView? {
        return composer
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EntryCell.self, forCellReuseIdentifier: "EntryCell")
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        composer.addTarget(self, action: #selector(handleSendHit), for: .primaryActionTriggered)
        composer.addTarget(self, action: #selector(handleSearchChange), for: .searchQueryChanged)
        composer.addTarget(self, action: #selector(handleComposerFocus), for: .editingDidBegin)

        // Provides secondary actions for entries
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        tableView.addGestureRecognizer(longPress)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.contentLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)

        Kit.observe(self, selector: #selector(stateChange))
    }

    @objc func stateChange() {
        let state = Kit.state
        if model.applyEntries(state) {
            tableView.reloadData()
            scrollToBottom(animated: true)
        }
        if model.applySearch(state) {
            tableView.reloadData()
            scrollToBottom(animated: true)
        }
    }

    func scrollToBottom(animated: Bool) {
        guard model.entries.count > 0 else { return }
        let indexPath = IndexPath(row: model.entries.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }

    @objc func handleComposerFocus() {
        scrollToBottom(animated: true)
    }

    @objc func handleSendHit() {
        guard let text = composer.text else { return }
        do {
            try Kit.entryCreate(text)
        } catch {
            print(error)
        }
        composer.reload()
    }

    @objc func handleSearchChange(_ sender: Composer) {
        try! Kit.entrySearch(sender.query)
    }

    @objc func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else {
            return
        }
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

    func showActions(for entry: Entry) {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        vc.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            do {
                try Kit.entryDelete(entry: entry.id)
            } catch {
                print(error)
            }
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

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }

        let dir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let file = dir.appendingPathComponent("data.logger")

        let controller = UIActivityViewController(activityItems: [file], applicationActivities: nil)
        present(controller, animated: true, completion: nil)
    }

    // MARK: - Keyboard

    @objc func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }

        // Reset safe area insets
        additionalSafeAreaInsets = .zero

        // Apply new additional safe area insets, accounting for keyboard height
        let additionalHeight = endFrameValue.cgRectValue.size.height - view.safeAreaInsets.bottom
        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: additionalHeight, right: 0)
    }

    @objc func keyboardWillHide(notification: Notification) {
    }
}

extension EntriesTableVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell", for: indexPath) as? EntryCell else {
            fatalError("Unknown cell")
        }
        let entry = model.entries[indexPath.row]
        cell.configure(with: entry)
        cell.onHashtagTap = { [weak self] tag in self?.handleHashtag(tag) }
        cell.onLinkTap = { [weak self] url in self?.handleLink(url) }
        return cell
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
            return Array(entries.values).sorted { $0.created < $1.created }
        }
    }
}
