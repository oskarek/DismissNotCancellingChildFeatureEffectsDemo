import ComposableArchitecture
import UIKit

// MARK: - Reducer

@Reducer
struct FeatureX {
  struct State: Equatable {}

  enum Action {
    case onViewDidLoad
    case switchButtonTapped
  }

  var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .onViewDidLoad:
        return .run { send in
          while true {
            try await Task.sleep(for: .seconds(1))
            print("tick X")
          }
        }
      case .switchButtonTapped:
        return .none
      }
    }
  }
}

// MARK: - UI

class FeatureXViewController: UIViewController {
  let store: StoreOf<FeatureX>

  init(store: StoreOf<FeatureX>) {
    self.store = store
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white

    store.send(.onViewDidLoad)

    let label = UILabel()
    label.text = "X"
    label.font = UIFont.systemFont(ofSize: 48)

    let button = UIButton(type: .system)
    button.setTitle("Switch to Y", for: .normal)
    button.addTarget(self, action: #selector(switchButtonTapped), for: .touchUpInside)

    let stack = UIStackView(arrangedSubviews: [label, button])
    stack.axis = .vertical
    stack.alignment = .center
    stack.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }

  @objc func switchButtonTapped() {
    store.send(.switchButtonTapped)
  }
}
