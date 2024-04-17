import ComposableArchitecture
import UIKit

// MARK: - Reducer

@Reducer
struct FeatureB: Reducer {
  @ObservableState
  struct State: Equatable {
    var child: Child.State = .featureX(.init())
  }

  enum Action {
    case child(Child.Action)
  }

  @Reducer
  struct Child: Reducer {
    enum State: Equatable {
      case featureX(FeatureX.State)
      case featureY(FeatureY.State)
    }

    enum Action {
      case featureX(FeatureX.Action)
      case featureY(FeatureY.Action)
    }

    var body: some ReducerOf<Self> {
      EmptyReducer()
        .ifCaseLet(\.featureX, action: \.featureX) {
          FeatureX()
        }
        .ifCaseLet(\.featureY, action: \.featureY) {
          FeatureY()
        }
    }
  }

  @Dependency(\.dismiss) var dismiss

  var mainBody: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .child(.featureX(.switchButtonTapped)):
        state.child = .featureY(.init())
        return .none
      case .child(.featureY(.closeButtonTapped)):
        return .run { _ in await dismiss() }
      case .child:
        return .none
      }
    }
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.child, action: \.child) {
      Child()
    }

    mainBody
  }
}

// MARK: - UI

class FeatureBViewController: UIViewController {
  let store: StoreOf<FeatureB>

  init(store: StoreOf<FeatureB>) {
    self.store = store
    super.init(nibName: nil, bundle: nil)
  }

  private var currentChild: UIViewController? {
    didSet {
      if let oldValue {
        oldValue.willMove(toParent: nil)
        oldValue.view.removeFromSuperview()
        oldValue.removeFromParent()
      }
      if let currentChild {
        addChild(currentChild)
        currentChild.view.frame = view.bounds
        view.addSubview(currentChild.view)
        currentChild.didMove(toParent: self)
      }
    }
  }

  var viewHasAppeared = false
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard !viewHasAppeared else { return }
    viewHasAppeared = true

    observe { [weak self] in
      guard let self else { return }
      switch store.child {
      case .featureX:
        if let currentChild, currentChild is FeatureXViewController { return }
        if let store = store.scope(state: \.child.featureX, action: \.child.featureX) {
          currentChild = FeatureXViewController(store: store)
        }
      case .featureY:
        if let currentChild, currentChild is FeatureYViewController { return }
        if let store = store.scope(state: \.child.featureY, action: \.child.featureY) {
          currentChild = FeatureYViewController(store: store)
        }
      }
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
