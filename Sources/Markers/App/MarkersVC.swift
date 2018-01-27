import UIKit
import Kit

class MarkersVC: UITableViewController {

    private var model = MarkersModel()
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

        tableView.register(MarkerCell.self, forCellReuseIdentifier: "MarkerCell")
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)

        composer.addTarget(self, action: #selector(handleSendHit), for: .primaryActionTriggered)

        Kit.subscribe(self, action: MarkersVC.appUpdate)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
        scrollToBottom(animated: false)
        shouldScrollToBottom = false
    }

    func appUpdate(state: State) {
        let priorMarkers = model.markers
        if model.applyMarkers(state) {
            tableView.apply(old: priorMarkers, new: model.markers, section: 0, animation: UITableViewRowAnimation.none)
            scrollToBottom(animated: true)
        }
    }

    func scrollToBottom(animated: Bool) {
        guard shouldScrollToBottom else { return }
        let indexPath = IndexPath(row: model.markers.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }

    @objc func handleSendHit(_ sender: Composer) {
        guard let text = sender.text else { return }
        shouldScrollToBottom = true
        Kit.insert(marker: text)
        sender.clear()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.markers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MarkerCell", for: indexPath) as? MarkerCell else {
            fatalError("Unknown cell")
        }
        let marker = model.markers[indexPath.row]
        cell.configure(with: marker)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
    }
}

struct MarkersModel {
    var markers: [Marker] = []

    mutating func applyMarkers(_ state: State) -> Bool {
        let stateMarkers = Array(state.markers.values).sorted { $0.created < $1.created }
        guard markers != stateMarkers else { return false }
        self.markers = stateMarkers
        return true
    }
}
