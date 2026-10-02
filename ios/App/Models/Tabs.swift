//
//  Tabs.swift
//  LitLoop
//
//  Created by Nebiyu Talefe on 2026/7/18.
//

import HotwireNative
import UIKit

// Tab icons live in Assets.xcassets/Icons (generated from the root icons/ directory
// by `cd backend && bundle exec rake theme:generate`).

private let homeTab = HotwireTab(
    title: "Home",
    image: UIImage(named: "Icons/Home")!,
    selectedImage: UIImage(named: "Icons/HomeSolid"),
    url: baseURL.appending(path: "")
)

private let libraryTab = HotwireTab(
    title: "Library",
    image: UIImage(named: "Icons/Library")!,
    selectedImage: UIImage(named: "Icons/LibrarySolid"),
    url: baseURL.appending(path: "library")
)

private let clubsTab = HotwireTab(
    title: "Clubs",
    image: UIImage(named: "Icons/Clubs")!,
    selectedImage: UIImage(named: "Icons/ClubsSolid"),
    url: baseURL.appending(path: "book_clubs")
)

private let profileTab = HotwireTab(
    title: "Profile",
    image: UIImage(named: "Icons/Profile")!,
    selectedImage: UIImage(named: "Icons/ProfileSolid"),
    url: baseURL.appending(path: "profile")
)

extension HotwireTab {
    static let all = [
        homeTab,
        libraryTab,
        clubsTab,
        profileTab,
    ]
}
