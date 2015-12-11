// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//


// Compound predicates are predicates which act on the results of evaluating other operators. We provide the basic boolean operators: AND, OR, and NOT.

public enum NSCompoundPredicateType : UInt {
    
    case NotPredicateType
    case AndPredicateType
    case OrPredicateType
}

public class NSCompoundPredicate : NSPredicate {
    
    public init(type: NSCompoundPredicateType, subpredicates: [NSPredicate]) {
        if type == .NotPredicateType && subpredicates.count == 0 {
            preconditionFailure("Unsupported predicate count of \(subpredicates.count) for NSCompoundPredicateType.NotPredicateType")
        }
        self.compoundPredicateType = type
        self.subpredicates = subpredicates
        super.init(block: { _ -> Bool in
            return false // will never be run in NSCompoundPredicate. replacing this with fatalError/preconditionFailure causes a false compiler error.
        })
    }
    public required init?(coder: NSCoder) { NSUnimplemented() }
    
    public let compoundPredicateType: NSCompoundPredicateType
    public let subpredicates: [AnyObject]

    /*** Convenience Methods ***/
    public convenience init(andPredicateWithSubpredicates subpredicates: [NSPredicate]) {
        self.init(type: .AndPredicateType, subpredicates: subpredicates)
    }
    public convenience init(orPredicateWithSubpredicates subpredicates: [NSPredicate]) {
        self.init(type: .OrPredicateType, subpredicates: subpredicates)
    }
    public convenience init(notPredicateWithSubpredicate predicate: NSPredicate) {
        self.init(type: .NotPredicateType, subpredicates: [predicate])
    }

    override public func evaluateWithObject(object: AnyObject?, substitutionVariables bindings: [String : AnyObject]?) -> Bool {
        let predicates = self.subpredicates as! [NSPredicate]

        switch compoundPredicateType {
        case .AndPredicateType:
            return predicates.reduce(true, combine: { $0 && $1.evaluateWithObject(object, substitutionVariables: bindings) })
        case .OrPredicateType:
            return predicates.reduce(false, combine: { $0 || $1.evaluateWithObject(object, substitutionVariables: bindings) })
        case .NotPredicateType:
            return !(predicates[0].evaluateWithObject(object, substitutionVariables: bindings))
        }
    }
}
