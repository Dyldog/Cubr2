//
//  ProgressView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 24/6/2025.
//

import DylKit
import SwiftUI

struct LearningProgressView: View {
    let events: [LearningEvent]
    let maxCount: Int
    let onSuccess: () -> Void
    let onFail: () -> Void
    let onNext: () -> Void
    
    let itemSize: CGFloat = 50
    let itemSpacing: CGFloat = 12
    let buttonSize: CGFloat = 80
    let smallButtonSize: CGFloat = 50
    
    var paddedEvents: [LearningEvent?] {
        (events as [LearningEvent?]).pad(toLength: 3, with: LearningEvent?.none)
    }
    
    var visibleWidth: CGFloat {
        3 * itemSize + 2 * itemSpacing
    }
    
    var hasLearned: Bool {
        events.suffix(LearningEvent.countForLearned) == [.success].repeated(3)
    }
    
    var showNext: Bool {
        events.count >= maxCount
    }
    
    init(
        events: [LearningEvent],
        maxCount: Int = LearningEvent.countForLearned,
        onSuccess: @escaping () -> Void,
        onFail: @escaping () -> Void,
        onNext: @escaping () -> Void
    ) {
        self.events = events
        self.maxCount = maxCount
        self.onSuccess = onSuccess
        self.onFail = onFail
        self.onNext = onNext
    }
    var body: some View {
        VStack(spacing: 0) {
            eventsView
            answerButtons
        }
        .padding([.horizontal, .bottom])
        .padding([.bottom])
    }
    
    private var eventsView: some View {
        ScrollView(.horizontal) {
            HStack(spacing: itemSpacing) {
                ForEach(paddedEvents) { event in
                    view(for: event, size: itemSize)
                }
            }
            .padding(.vertical, 48)
        }
        .frame(width: visibleWidth)
        .defaultScrollAnchor(.trailing)
        .scrollClipDisabled()
        .scrollIndicators(.hidden)
    }
    
    private var answerButtons: some View {
        HStack(spacing: 48) {
            Button {
                onFail()
            } label: {
                view(for: .fail, size: showNext ? smallButtonSize : buttonSize, fill: true)
            }
            
            if showNext {
                Button {
                    onNext()
                } label: {
                    view(
                        for: Image(systemName: "arrow.right"),
                        size: buttonSize,
                        fill: true
                    )
                }
            }
            
            Button {
                onSuccess()
            } label: {
                view(for: .success, size: showNext ? smallButtonSize : buttonSize, fill: true)
            }

        }
    }
    private func view(
        for event: LearningEvent?,
        size: CGFloat = 30,
        lineWidth: CGFloat = 4,
        fill: Bool = false
    ) -> some View {
        view(for: event.image, size: size, lineWidth: lineWidth, fill: fill)
    }
    
    private func view(
        for image: Image,
        size: CGFloat = 30,
        lineWidth: CGFloat = 4,
        fill: Bool = false
    ) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .bold()
            .padding(size / 4)
            .foregroundStyle(fill ? .white : .accentColor)
            .frame(width: size, height: size)
            .background {
                Circle()
                    .if(fill) {
                        $0.fill(Color.accentColor)
                    } `else`: {
                        $0.stroke(Color.accentColor, lineWidth: lineWidth)
                    }
            }
    }
}

enum LearningEvent: Int, Codable {
    case fail
    case successWithHint
    case success
    
    static let countForLearned: Int = 3
    
    static let countForMoveToLearned: Int = countForLearned * countForLearned
    
    static func nextCountForLearned(after count: Int) -> Int {
        let countMultiples = Int((Float(count) / Float(countForLearned)).rounded(.down))
        return countForLearned * (countMultiples + 1)
    }
    
    private var imageName: String {
        switch self {
        case .success: "checkmark"
        case .fail: "xmark"
        case .successWithHint: "questionmark"
        }
    }
    
    var image: Image {
        .init(systemName: imageName)
    }
}

extension LearningEvent: Comparable {
    static func < (lhs: LearningEvent, rhs: LearningEvent) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
extension Optional where Wrapped == LearningEvent {
    var image: Image {
        switch self {
        case .none: Image(uiImage: UIImage())
        case let .some(event): event.image
        }
    }
}
