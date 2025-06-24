//
//  Zip.swift
//  Cubr2
//
//  Created by Dylan Elliott on 19/6/2025.
//

import Foundation

// zip3

// Given three sequences, return a sequence of 3-tuples
public func zip3<A: Sequence, B: Sequence, C: Sequence>(a: A, b: B, c: C)
    -> ZipSequence3<A, B, C>
{
    return ZipSequence3(a, b, c)
}

// Sequence of tuples created from values from three other sequences
public struct ZipSequence3<A: Sequence, B: Sequence, C: Sequence>: Sequence {
    private var a: A
    private var b: B
    private var c: C
    
    public init (_ a: A, _ b: B, _ c: C) {
        self.a = a
        self.b = b
        self.c = c
    }
    
    public func makeIterator() -> ZipGenerator3<A.Iterator, B.Iterator, C.Iterator> {
        return ZipGenerator3(a.makeIterator(), b.makeIterator(), c.makeIterator())
    }
}

// Generator that creates tuples of values from three other generators
public struct ZipGenerator3<A: IteratorProtocol, B: IteratorProtocol, C: IteratorProtocol>: IteratorProtocol {
    private var a: A
    private var b: B
    private var c: C
    
    public init(_ a: A, _ b: B, _ c: C) {
        self.a = a
        self.b = b
        self.c = c
    }
    
    mutating public func next() -> (A.Element, B.Element, C.Element)? {
        switch (a.next(), b.next(), c.next()) {
        case let (.some(aValue), .some(bValue), .some(cValue)):
            return (aValue, bValue, cValue)
        default:
            return nil
        }
    }
}
