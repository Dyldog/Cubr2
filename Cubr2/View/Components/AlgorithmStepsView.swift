//
//  AlgorithmStepsView.swift
//  Cubr2
//
//  Created by Dylan Elliott on 14/6/2025.
//

import DylKit
import SwiftUI

enum AlgorithmStepViewError: Error {
    case multipleRangesSelected
}

struct AlgorithmStepsView: View {
    let steps: [String]
    let mnemonics: [StepMnemonic]
    let canEdit: Bool
    let shownItems: Range<Int>?
    @State var highlightedItems: [Bool]
    
    @State var highlightedMnemonicTitle: String = ""
    @State var editingMnemonic: StepMnemonic?
    @FocusState var keyboardFocused: Bool
    
    let updateMnemonic: ((UUID?, StepMnemonic?) -> Void)?
    
    var highlighteRange: Range<Int>? {
        try? range(for: highlightedItems)
    }
    
    init(
        steps: [String],
        mnemonics: [StepMnemonic],
        shownItems: Range<Int>? = nil,
        updateMnemonic: ((UUID?, StepMnemonic?) -> Void)?
    ) {
        self.steps = steps
        self.mnemonics = mnemonics
        self.canEdit = updateMnemonic != nil
        self.shownItems = shownItems
        self.updateMnemonic = updateMnemonic
        self._highlightedItems = .init(initialValue: .init(
            repeating: false,
            count: steps.count - mnemonics.map { $0.range.count - 1 }.sum()
        ))
    }
    
    var items: [Item] {
        let allItems = steps.algorithmItems(with: mnemonics.filter { $0.id != editingMnemonic?.id })
        return shownItems.map { allItems[$0].array } ?? allItems
    }
    
    var body: some View {
        if highlighteRange != nil {
            TextField("Mmnemonic Title", text: $highlightedMnemonicTitle)
                .focused($keyboardFocused)
                .textFieldStyle(.roundedBorder)
                .labelsHidden()
                .onAppear {
                    keyboardFocused = true
                }
                .onSubmit {
                    mnemonicDoneTapped()
                }
        }
        stepsView
            .id(mnemonics)
    }
    
    private var stepsView: some View {
        WrappingHStack(verticalSpacing: 8) {
            ForEach(enumerated: items) { index, item in
                switch item {
                case let .step(step):
                    StepButton(step: step, highlighted: highlightedItems[safe: index] ?? false) {
                        stepTapped(at: index)
                    }
                case let .mnemonic(mnemonic, _):
                    MnemonicButton(text: mnemonic.text, highlighted: highlightedItems[safe: index] ?? false) {
                        stepTapped(at: index)
                    }
                }
            }
        }
    }
    
    private func range(for highlights: [Bool]) throws -> Range<Int>? {
        guard highlights
            .split(separator: false, omittingEmptySubsequences: true).count <= 1
        else { throw AlgorithmStepViewError.multipleRangesSelected }
        
        let startIndex = highlights.firstIndex { $0 == true }
        let length = highlights.filter { $0 == true }.count
        return startIndex.map { ($0 ..< ($0 + length)) }
    }
    
    private func stepTapped(at index: Int) {
        guard updateMnemonic != nil else { return }

        var newHighlights = highlightedItems
        newHighlights[index].toggle()
        var newRange: Range<Int>?
        
        do {
            newRange = try range(for: newHighlights)
        } catch {
            return
        }
        
        if newRange?.count == 1, case let .mnemonic(mnemonic, steps) = items[index] {
            editingMnemonic = mnemonic
            highlightedMnemonicTitle = mnemonic.text
            newHighlights.remove(at: index)
            newHighlights.insert(contentsOf: Array(repeating: true, count: steps.count), at: index)
        } else if newRange == nil {
            editingMnemonic = nil
            highlightedMnemonicTitle = ""
        } else {
            // It's a regular step
        }
        
        highlightedItems = newHighlights
    }
    
    private func mnemonicDoneTapped() {
        guard let updateMnemonic else { return }
        guard let highlighteRange else { return }
        
        let actualOffset = items
            .dropLast(items.count - highlighteRange.lowerBound)
            .reduce(0) { partialResult, item in
                switch item {
                case let .mnemonic(_, steps): partialResult + steps.count
                case .step: partialResult + 1
                }
            }
        
        let actualRange = (actualOffset ..< actualOffset + highlighteRange.count)
        
        let existingMnemonic = mnemonics.first { $0.range.overlaps(actualRange) }
        
        if highlightedMnemonicTitle.isEmpty {
            updateMnemonic(existingMnemonic?.id, nil)
        } else {
            updateMnemonic(existingMnemonic?.id, .init(
                id: .init(),
                text: highlightedMnemonicTitle,
                location: actualRange.lowerBound,
                length: actualRange.count
            ))
        }
        
        self.editingMnemonic = nil
        self.highlightedMnemonicTitle = ""
        self.highlightedItems = .init(
            repeating: false,
            count: steps.count - mnemonics.map { $0.range.count - 1 }.sum()
        )
    }
    
    enum Item {
        case step(String)
        case mnemonic(StepMnemonic, [String])
    }
}

extension Array where Element == String {
    typealias Item = AlgorithmStepsView.Item
    
    func algorithmItems(
        with mnemonics: [StepMnemonic]
    ) -> [Item] {
        var items: [Item?] = self.map { .step($0) }
        
        mnemonics.forEach { mnemonic in
//            guard mnemonic.id != editingMnemonic?.id else { return }
            mnemonic.range.forEach { location in
                items[location] = nil
            }
            items[mnemonic.location] = .mnemonic(mnemonic, self[mnemonic.range].array)
        }
        
        return items.compactMap { $0 }
        
//        return shownItems.map { mappedItems[$0].array } ?? mappedItems
    }
}
