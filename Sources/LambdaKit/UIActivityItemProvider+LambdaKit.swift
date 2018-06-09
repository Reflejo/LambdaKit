import Social
import UIKit

public class ActivityClosureProvider<T>: UIActivityItemProvider {
    /// A closure that takes an activity item and returns the specialized type for this provider
    public typealias ItemClosure = (UIActivityViewController, String) -> (T?)
    /// A closure that takes an activity item and returns a user-facing subject for activies that support it.
    public typealias SubjectClosure = (UIActivityViewController, String?) -> String

    private let itemClosure: ItemClosure
    private let subjectClosure: SubjectClosure?

    /// Creates a new provider.
    ///
    /// - parameter placeholderItem: A placeholder whose type must match the class of the object that is
    ///                              provided later.
    /// - parameter subjectClosure:  A closure that returns a user-facing subject, if applicable.
    /// - parameter itemClosure:     A closure that returns the specialized item.
    public init(placeholderItem: Any, subjectClosure: SubjectClosure? = nil,
                itemClosure: @escaping ItemClosure)
    {
        self.subjectClosure = subjectClosure
        self.itemClosure = itemClosure
        super.init(placeholderItem: placeholderItem)
    }

    public override func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?) -> Any?
    {
        return (activityType?.rawValue).flatMap { self.itemClosure(activityViewController, $0) }
    }

    public override func activityViewController(
        _ activityViewController: UIActivityViewController,
        subjectForActivityType activityType: UIActivity.ActivityType?) -> String
    {
        return self.subjectClosure?(activityViewController, activityType?.rawValue) ?? ""
    }
}

public final class ActivityStringProvider: ActivityClosureProvider<NSString> {
    /// Creates a class for easily sharing strings.
    ///
    /// - parameter subjectClosure: A closure that returns a user-facing subject, if applicable.
    /// - parameter itemClosure:    A closure that returns the string that will be shared.
    public init(subjectClosure: SubjectClosure? = nil, itemClosure: @escaping ItemClosure) {
        super.init(placeholderItem: "", subjectClosure: subjectClosure, itemClosure: itemClosure)
    }
}

public final class ActivityURLProvider: ActivityClosureProvider<URL> {
    /// Creates a class for easily sharing URLs.
    ///
    /// - parameter itemClosure: A closure that returns the URL that will be shared.
    public init(itemClosure: @escaping ItemClosure) {
        super.init(placeholderItem: URL(string: "https://www.example.com/")!, itemClosure: itemClosure)
    }
}
