import ComposableArchitecture
import UIKit

// MARK: - Reducer

@Reducer
struct FeatureY {
  struct State: Equatable {}

  enum Action {
    case closeButtonTapped
    case onAppear
  }

  var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .closeButtonTapped:
        return .none
      case .onAppear:
        return .run { send in
          while true {
            try await Task.sleep(for: .seconds(1))
            print("tick Y")
          }
        }
      }
    }
  }
}


// MARK: - UI

class FeatureYViewController: UIViewController {
  let store: StoreOf<FeatureY>

  init(store: StoreOf<FeatureY>) {
    self.store = store
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white

    let label = UILabel()
    label.text = "Y"
    label.font = UIFont.systemFont(ofSize: 48)

    let button = UIButton(type: .system)
    button.setTitle("Close", for: .normal)
    button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

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

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    store.send(.onAppear)
  }

  @objc func closeButtonTapped() {
    store.send(.closeButtonTapped)
  }
}
