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
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        composer.addTarget(self, action: #selector(handleSendHit), for: .primaryActionTriggered)
        composer.addTarget(self, action: #selector(handleSearchChange), for: .searchQueryChanged)

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        composer.textView.becomeFirstResponder()
    }

    @objc func stateChange() {
        if model.applyEntries(Kit.state) {
            tableView.reloadData()
            scrollToBottom(animated: true)
        }
        if model.applySearch(Kit.state) {
            tableView.reloadData()
        }
    }

    func scrollToBottom(animated: Bool) {
        guard model.entries.count > 0 else { return }
        let indexPath = IndexPath(row: model.entries.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
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

    func handleHashtag(_ tag: String) {
        var query = tag
        query.removeFirst(3)
        composer.query = query
        try! Kit.entrySearch(query)
    }

    func handleLink(_ link: String) {
        guard let url = URL(string: link) else { return }
        let controller = SFSafariViewController(url: url)
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

    override func viewSafeAreaInsetsDidChange() {
        //print(view.safeAreaInsets)
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
        cell.onLinkTap = { [weak self] link in self?.handleLink(link) }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }

        let entry = model.entries[indexPath.row]
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        vc.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            try! Kit.entryDelete(entry: entry.id)
        })
        present(vc, animated: true, completion: nil)
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
            return ids.map { entries[$0] }.flatMap{ $0 }
        } else {
            return Array(entries.values).sorted { $0.created < $1.created }
        }
    }
}
