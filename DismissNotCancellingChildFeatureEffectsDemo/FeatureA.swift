import ComposableArchitecture
import UIKit

// MARK: - Reducer

@Reducer
struct FeatureA: Reducer {
  @ObservableState
  struct State: Equatable {
    @Presents var destination: Destination.State?
  }

  enum Action {
    case destination(PresentationAction<Destination.Action>)
    case presentButtonTapped
  }

  @Reducer(state: .equatable)
  enum Destination {
    case featureB(FeatureB)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .destination:
        return .none
      case .presentButtonTapped:
        state.destination = .featureB(.init())
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
}

// MARK: - UI

class FeatureAViewController: UIViewController {
  let store: StoreOf<FeatureA>

  init(store: StoreOf<FeatureA>) {
    self.store = store
    super.init(nibName: nil, bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white

    let button = UIButton(type: .system)
    button.setTitle("Present B", for: .normal)
    button.addTarget(self, action: #selector(presentButtonTapped), for: .touchUpInside)
    button.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
    button.center = view.center
    view.addSubview(button)

    var featureBVC: FeatureBViewController?
    observe { [weak self] in
      guard let self else { return }
      if
        let scopedStore = store.scope(state: \.destination, action: \.destination),
        let featureBStore = scopedStore.scope(state: \.featureB, action: \.featureB.presented),
        featureBVC == nil
      {
        featureBVC = FeatureBViewController(store: featureBStore)
        featureBVC?.modalPresentationStyle = .automatic
        DispatchQueue.main.async { [weak self] in
          self?.present(featureBVC!, animated: true, completion: nil)
        }
      } else if store.destination?.featureB == nil, featureBVC != nil {
        dismiss(animated: true)
        featureBVC = nil
      }
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func presentButtonTapped() {
    store.send(.presentButtonTapped)
  }
}
