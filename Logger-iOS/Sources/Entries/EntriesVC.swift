import UIKit
import LoggerKit

class EntriesVC: UITableViewController {

    private var model = EntriesModel()
    private var composer = Composer()
    private var shouldScrollToBottom = true

    override var inputAccessoryView: UIView? {
        return composer
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(EntryCell.self, forCellReuseIdentifier: "EntryCell")
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)

        composer.addTarget(self, action: #selector(handleSendHit), for: .primaryActionTriggered)

        Kit.observe(self, selector: #selector(stateChange))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
        scrollToBottom(animated: false)
        shouldScrollToBottom = false
    }

    @objc func stateChange() {
        if model.applyEntries(Kit.state) {
            tableView.reloadData()
        }
    }

    func scrollToBottom(animated: Bool) {
        guard shouldScrollToBottom && model.entries.count > 0 else { return }
        let indexPath = IndexPath(row: model.entries.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }

    @objc func handleSendHit(_ sender: Composer) {
        guard let text = sender.text else { return }
        shouldScrollToBottom = true
        try! Kit.entryCreate(text)
        sender.clear()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.entries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell", for: indexPath) as? EntryCell else {
            fatalError("Unknown cell")
        }
        let entry = model.entries[indexPath.row]
        cell.configure(with: entry)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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

    mutating func applyEntries(_ state: State) -> Bool {
        let stateEntries = Array(state.entries.values).sorted { $0.created < $1.created }
        guard entries != stateEntries else { return false }
        self.entries = stateEntries
        return true
    }
}
