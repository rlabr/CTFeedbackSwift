//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import UIKit

public class FeedbackItemsDataSource {
    var sections: [FeedbackItemsSection] = []

    var numberOfSections: Int {
        return sections.filter { section in
            section.items.filter { !$0.isHidden }.isEmpty == false
        }.count
    }

    public init(topics: [TopicProtocol],
                hidesUserEmailCell: Bool = true,
                hidesAttachmentCell: Bool = false,
                hidesAppInfoSection: Bool = false) {
        sections.append(FeedbackItemsSection(title: CTLocalizedString("CTFeedback.UserDetail"),
                                             items: [UserEmailItem(isHidden: false)]))
        sections.append(FeedbackItemsSection(items: [TopicItem(topics), BodyItem()]))
        sections.append(FeedbackItemsSection(title: CTLocalizedString("CTFeedback.AdditionalInfo"),
                                             items: [AttachmentItem(isHidden: hidesAttachmentCell)]))
        sections.append(FeedbackItemsSection(title: CTLocalizedString("CTFeedback.DeviceInfo"),
                                             items: [DeviceNameItem(),
                                                     SystemVersionItem()]))
        sections.append(FeedbackItemsSection(title: CTLocalizedString("CTFeedback.AppInfo"),
                                             items: [AppNameItem(isHidden: hidesAppInfoSection),
                                                     AppVersionItem(isHidden: hidesAppInfoSection),
                                                     AppBuildItem(isHidden: hidesAppInfoSection)]))
    }

    func section(at section: Int) -> FeedbackItemsSection {
        return sections.filter { section in
            section.items.filter { !$0.isHidden }.isEmpty == false
        }[section]
    }
}

extension FeedbackItemsDataSource: TopicsRepositoryProtocol {
    public var topics: [TopicProtocol] {
        get { return item(of: TopicItem.self)?.topics ?? [] }
        set {
            guard var item = item(of: TopicItem.self) else { return }
            item.topics = newValue
            set(item: item)
        }
    }
}

extension FeedbackItemsDataSource {
    private subscript(indexPath: IndexPath) -> FeedbackItemProtocol {
        get { return sections[indexPath.section][indexPath.item] }
        set { sections[indexPath.section][indexPath.item] = newValue }
    }

    private func indexPath<Item>(of type: Item.Type) -> IndexPath? {
        for section in sections {
            guard let index = sections.index(where: { $0 === section }),
                  let subIndex = section.items.index(where: { $0 is Item })
                else { continue }
            return IndexPath(item: subIndex, section: index)
        }
        return .none
    }
}

extension FeedbackItemsDataSource: FeedbackEditingItemsRepositoryProtocol {
    public func item<Item>(of type: Item.Type) -> Item? {
        guard let indexPath = indexPath(of: type) else { return .none }
        return self[indexPath] as? Item
    }

    @discardableResult
    public func set<Item:FeedbackItemProtocol>(item: Item) -> IndexPath? {
        guard let indexPath = indexPath(of: Item.self) else { return .none }
        self[indexPath] = item
        return indexPath
    }
}

class FeedbackItemsSection {
    let title: String?
    var items: [FeedbackItemProtocol]

    init(title: String? = .none, items: [FeedbackItemProtocol]) {
        self.title = title
        self.items = items
    }
}

extension FeedbackItemsSection: Collection {
    var startIndex: Int { return items.startIndex }
    var endIndex:   Int { return items.endIndex }

    subscript(position: Int) -> FeedbackItemProtocol {
        get { return items[position] }
        set { items[position] = newValue }
    }

    func index(after i: Int) -> Int { return items.index(after: i) }
}
