//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import Rswift
import UIKit

/// This `R` struct is generated and contains references to static resources.
struct R: Rswift.Validatable {
  fileprivate static let applicationLocale = hostingBundle.preferredLocalizations.first.flatMap(Locale.init) ?? Locale.current
  fileprivate static let hostingBundle = Bundle(for: R.Class.self)

  /// Find first language and bundle for which the table exists
  fileprivate static func localeBundle(tableName: String, preferredLanguages: [String]) -> (Foundation.Locale, Foundation.Bundle)? {
    // Filter preferredLanguages to localizations, use first locale
    var languages = preferredLanguages
      .map(Locale.init)
      .prefix(1)
      .flatMap { locale -> [String] in
        if hostingBundle.localizations.contains(locale.identifier) {
          if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
            return [locale.identifier, language]
          } else {
            return [locale.identifier]
          }
        } else if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
          return [language]
        } else {
          return []
        }
      }

    // If there's no languages, use development language as backstop
    if languages.isEmpty {
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages = [developmentLocalization]
      }
    } else {
      // Insert Base as second item (between locale identifier and languageCode)
      languages.insert("Base", at: 1)

      // Add development language as backstop
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages.append(developmentLocalization)
      }
    }

    // Find first language for which table exists
    // Note: key might not exist in chosen language (in that case, key will be shown)
    for language in languages {
      if let lproj = hostingBundle.url(forResource: language, withExtension: "lproj"),
         let lbundle = Bundle(url: lproj)
      {
        let strings = lbundle.url(forResource: tableName, withExtension: "strings")
        let stringsdict = lbundle.url(forResource: tableName, withExtension: "stringsdict")

        if strings != nil || stringsdict != nil {
          return (Locale(identifier: language), lbundle)
        }
      }
    }

    // If table is available in main bundle, don't look for localized resources
    let strings = hostingBundle.url(forResource: tableName, withExtension: "strings", subdirectory: nil, localization: nil)
    let stringsdict = hostingBundle.url(forResource: tableName, withExtension: "stringsdict", subdirectory: nil, localization: nil)

    if strings != nil || stringsdict != nil {
      return (applicationLocale, hostingBundle)
    }

    // If table is not found for requested languages, key will be shown
    return nil
  }

  /// Load string from Info.plist file
  fileprivate static func infoPlistString(path: [String], key: String) -> String? {
    var dict = hostingBundle.infoDictionary
    for step in path {
      guard let obj = dict?[step] as? [String: Any] else { return nil }
      dict = obj
    }
    return dict?[key] as? String
  }

  static func validate() throws {
    try intern.validate()
  }

  #if os(iOS) || os(tvOS)
  /// This `R.storyboard` struct is generated, and contains static references to 2 storyboards.
  struct storyboard {
    /// Storyboard `LaunchScreen`.
    static let launchScreen = _R.storyboard.launchScreen()
    /// Storyboard `Main`.
    static let main = _R.storyboard.main()

    #if os(iOS) || os(tvOS)
    /// `UIStoryboard(name: "LaunchScreen", bundle: ...)`
    static func launchScreen(_: Void = ()) -> UIKit.UIStoryboard {
      return UIKit.UIStoryboard(resource: R.storyboard.launchScreen)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIStoryboard(name: "Main", bundle: ...)`
    static func main(_: Void = ()) -> UIKit.UIStoryboard {
      return UIKit.UIStoryboard(resource: R.storyboard.main)
    }
    #endif

    fileprivate init() {}
  }
  #endif

  /// This `R.file` struct is generated, and contains static references to 1 files.
  struct file {
    /// Resource file `countries`.
    static let countries = Rswift.FileResource(bundle: R.hostingBundle, name: "countries", pathExtension: "")

    /// `bundle.url(forResource: "countries", withExtension: "")`
    static func countries(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.countries
      return fileResource.bundle.url(forResource: fileResource)
    }

    fileprivate init() {}
  }

  /// This `R.image` struct is generated, and contains static references to 21 images.
  struct image {
    /// Image `add`.
    static let add = Rswift.ImageResource(bundle: R.hostingBundle, name: "add")
    /// Image `arrow_back`.
    static let arrow_back = Rswift.ImageResource(bundle: R.hostingBundle, name: "arrow_back")
    /// Image `arrow_down`.
    static let arrow_down = Rswift.ImageResource(bundle: R.hostingBundle, name: "arrow_down")
    /// Image `arrow_right_bold`.
    static let arrow_right_bold = Rswift.ImageResource(bundle: R.hostingBundle, name: "arrow_right_bold")
    /// Image `arrow_right_circle`.
    static let arrow_right_circle = Rswift.ImageResource(bundle: R.hostingBundle, name: "arrow_right_circle")
    /// Image `arrow_right`.
    static let arrow_right = Rswift.ImageResource(bundle: R.hostingBundle, name: "arrow_right")
    /// Image `close`.
    static let close = Rswift.ImageResource(bundle: R.hostingBundle, name: "close")
    /// Image `folder`.
    static let folder = Rswift.ImageResource(bundle: R.hostingBundle, name: "folder")
    /// Image `icon_80`.
    static let icon_80 = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon_80")
    /// Image `icon`.
    static let icon = Rswift.ImageResource(bundle: R.hostingBundle, name: "icon")
    /// Image `lock`.
    static let lock = Rswift.ImageResource(bundle: R.hostingBundle, name: "lock")
    /// Image `notebook`.
    static let notebook = Rswift.ImageResource(bundle: R.hostingBundle, name: "notebook")
    /// Image `option`.
    static let option = Rswift.ImageResource(bundle: R.hostingBundle, name: "option")
    /// Image `paper_dark`.
    static let paper_dark = Rswift.ImageResource(bundle: R.hostingBundle, name: "paper_dark")
    /// Image `paper_light`.
    static let paper_light = Rswift.ImageResource(bundle: R.hostingBundle, name: "paper_light")
    /// Image `search`.
    static let search = Rswift.ImageResource(bundle: R.hostingBundle, name: "search")
    /// Image `setting`.
    static let setting = Rswift.ImageResource(bundle: R.hostingBundle, name: "setting")
    /// Image `share_to`.
    static let share_to = Rswift.ImageResource(bundle: R.hostingBundle, name: "share_to")
    /// Image `unlock`.
    static let unlock = Rswift.ImageResource(bundle: R.hostingBundle, name: "unlock")
    /// Image `user`.
    static let user = Rswift.ImageResource(bundle: R.hostingBundle, name: "user")
    /// Image `write`.
    static let write = Rswift.ImageResource(bundle: R.hostingBundle, name: "write")

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "add", bundle: ..., traitCollection: ...)`
    static func add(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.add, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "arrow_back", bundle: ..., traitCollection: ...)`
    static func arrow_back(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.arrow_back, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "arrow_down", bundle: ..., traitCollection: ...)`
    static func arrow_down(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.arrow_down, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "arrow_right", bundle: ..., traitCollection: ...)`
    static func arrow_right(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.arrow_right, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "arrow_right_bold", bundle: ..., traitCollection: ...)`
    static func arrow_right_bold(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.arrow_right_bold, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "arrow_right_circle", bundle: ..., traitCollection: ...)`
    static func arrow_right_circle(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.arrow_right_circle, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "close", bundle: ..., traitCollection: ...)`
    static func close(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.close, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "folder", bundle: ..., traitCollection: ...)`
    static func folder(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.folder, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "icon", bundle: ..., traitCollection: ...)`
    static func icon(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "icon_80", bundle: ..., traitCollection: ...)`
    static func icon_80(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.icon_80, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "lock", bundle: ..., traitCollection: ...)`
    static func lock(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.lock, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "notebook", bundle: ..., traitCollection: ...)`
    static func notebook(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.notebook, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "option", bundle: ..., traitCollection: ...)`
    static func option(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.option, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "paper_dark", bundle: ..., traitCollection: ...)`
    static func paper_dark(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.paper_dark, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "paper_light", bundle: ..., traitCollection: ...)`
    static func paper_light(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.paper_light, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "search", bundle: ..., traitCollection: ...)`
    static func search(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.search, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "setting", bundle: ..., traitCollection: ...)`
    static func setting(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.setting, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "share_to", bundle: ..., traitCollection: ...)`
    static func share_to(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.share_to, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "unlock", bundle: ..., traitCollection: ...)`
    static func unlock(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.unlock, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "user", bundle: ..., traitCollection: ...)`
    static func user(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.user, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "write", bundle: ..., traitCollection: ...)`
    static func write(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.write, compatibleWith: traitCollection)
    }
    #endif

    fileprivate init() {}
  }

  /// This `R.nib` struct is generated, and contains static references to 7 nibs.
  struct nib {
    /// Nib `BrokenNoteCell`.
    static let brokenNoteCell = _R.nib._BrokenNoteCell()
    /// Nib `NoteCell`.
    static let noteCell = _R.nib._NoteCell()
    /// Nib `NotebookCell`.
    static let notebookCell = _R.nib._NotebookCell()
    /// Nib `NotebookHeader`.
    static let notebookHeader = _R.nib._NotebookHeader()
    /// Nib `NotebookSelectionView`.
    static let notebookSelectionView = _R.nib._NotebookSelectionView()
    /// Nib `PlaceholderViewController`.
    static let placeholderViewController = _R.nib._PlaceholderViewController()
    /// Nib `ProfileViewController`.
    static let profileViewController = _R.nib._ProfileViewController()

    #if os(iOS) || os(tvOS)
    /// `UINib(name: "BrokenNoteCell", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.brokenNoteCell) instead")
    static func brokenNoteCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.brokenNoteCell)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UINib(name: "NoteCell", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.noteCell) instead")
    static func noteCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.noteCell)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UINib(name: "NotebookCell", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.notebookCell) instead")
    static func notebookCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.notebookCell)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UINib(name: "NotebookHeader", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.notebookHeader) instead")
    static func notebookHeader(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.notebookHeader)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UINib(name: "NotebookSelectionView", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.notebookSelectionView) instead")
    static func notebookSelectionView(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.notebookSelectionView)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UINib(name: "PlaceholderViewController", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.placeholderViewController) instead")
    static func placeholderViewController(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.placeholderViewController)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UINib(name: "ProfileViewController", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.profileViewController) instead")
    static func profileViewController(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.profileViewController)
    }
    #endif

    static func brokenNoteCell(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> BrokenNoteCell? {
      return R.nib.brokenNoteCell.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? BrokenNoteCell
    }

    static func noteCell(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> NoteCell? {
      return R.nib.noteCell.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? NoteCell
    }

    static func notebookCell(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> NotebookCell? {
      return R.nib.notebookCell.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? NotebookCell
    }

    static func notebookHeader(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> NotebookHeader? {
      return R.nib.notebookHeader.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? NotebookHeader
    }

    static func notebookSelectionView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> NotebookSelectionView? {
      return R.nib.notebookSelectionView.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? NotebookSelectionView
    }

    static func placeholderViewController(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> PlaceholderViewController? {
      return R.nib.placeholderViewController.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? PlaceholderViewController
    }

    static func profileViewController(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> ProfileViewController? {
      return R.nib.profileViewController.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? ProfileViewController
    }

    fileprivate init() {}
  }

  /// This `R.reuseIdentifier` struct is generated, and contains static references to 2 reuse identifiers.
  struct reuseIdentifier {
    /// Reuse identifier `NOTEBOOKCELL`.
    static let notebookcelL: Rswift.ReuseIdentifier<NotebookCell> = Rswift.ReuseIdentifier(identifier: "NOTEBOOKCELL")
    /// Reuse identifier `NOTECELL`.
    static let notecelL: Rswift.ReuseIdentifier<NoteCell> = Rswift.ReuseIdentifier(identifier: "NOTECELL")

    fileprivate init() {}
  }

  fileprivate struct intern: Rswift.Validatable {
    fileprivate static func validate() throws {
      try _R.validate()
    }

    fileprivate init() {}
  }

  fileprivate class Class {}

  fileprivate init() {}
}

struct _R: Rswift.Validatable {
  static func validate() throws {
    #if os(iOS) || os(tvOS)
    try nib.validate()
    #endif
    #if os(iOS) || os(tvOS)
    try storyboard.validate()
    #endif
  }

  #if os(iOS) || os(tvOS)
  struct nib: Rswift.Validatable {
    static func validate() throws {
      try _NotebookCell.validate()
      try _NotebookHeader.validate()
      try _NotebookSelectionView.validate()
      try _ProfileViewController.validate()
    }

    struct _BrokenNoteCell: Rswift.NibResourceType {
      let bundle = R.hostingBundle
      let name = "BrokenNoteCell"

      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> BrokenNoteCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? BrokenNoteCell
      }

      fileprivate init() {}
    }

    struct _NoteCell: Rswift.NibResourceType, Rswift.ReuseIdentifierType {
      typealias ReusableType = NoteCell

      let bundle = R.hostingBundle
      let identifier = "NOTECELL"
      let name = "NoteCell"

      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> NoteCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? NoteCell
      }

      fileprivate init() {}
    }

    struct _NotebookCell: Rswift.NibResourceType, Rswift.ReuseIdentifierType, Rswift.Validatable {
      typealias ReusableType = NotebookCell

      let bundle = R.hostingBundle
      let identifier = "NOTEBOOKCELL"
      let name = "NotebookCell"

      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> NotebookCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? NotebookCell
      }

      static func validate() throws {
        if UIKit.UIImage(named: "arrow_right", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'arrow_right' is used in nib 'NotebookCell', but couldn't be loaded.") }
        if UIKit.UIImage(named: "folder", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'folder' is used in nib 'NotebookCell', but couldn't be loaded.") }
        if #available(iOS 11.0, tvOS 11.0, *) {
        }
      }

      fileprivate init() {}
    }

    struct _NotebookHeader: Rswift.NibResourceType, Rswift.Validatable {
      let bundle = R.hostingBundle
      let name = "NotebookHeader"

      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> NotebookHeader? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? NotebookHeader
      }

      static func validate() throws {
        if UIKit.UIImage(named: "arrow_right_bold", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'arrow_right_bold' is used in nib 'NotebookHeader', but couldn't be loaded.") }
        if #available(iOS 11.0, tvOS 11.0, *) {
        }
      }

      fileprivate init() {}
    }

    struct _NotebookSelectionView: Rswift.NibResourceType, Rswift.Validatable {
      let bundle = R.hostingBundle
      let name = "NotebookSelectionView"

      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> NotebookSelectionView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? NotebookSelectionView
      }

      static func validate() throws {
        if UIKit.UIImage(named: "folder", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'folder' is used in nib 'NotebookSelectionView', but couldn't be loaded.") }
        if #available(iOS 11.0, tvOS 11.0, *) {
        }
      }

      fileprivate init() {}
    }

    struct _PlaceholderViewController: Rswift.NibResourceType {
      let bundle = R.hostingBundle
      let name = "PlaceholderViewController"

      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> PlaceholderViewController? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? PlaceholderViewController
      }

      fileprivate init() {}
    }

    struct _ProfileViewController: Rswift.NibResourceType, Rswift.Validatable {
      let bundle = R.hostingBundle
      let name = "ProfileViewController"

      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> ProfileViewController? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? ProfileViewController
      }

      func secondView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[1] as? UIKit.UIView
      }

      func thirdView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[2] as? UIKit.UIView
      }

      static func validate() throws {
        if UIKit.UIImage(named: "setting", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'setting' is used in nib 'ProfileViewController', but couldn't be loaded.") }
        if UIKit.UIImage(named: "share_to", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'share_to' is used in nib 'ProfileViewController', but couldn't be loaded.") }
        if #available(iOS 11.0, tvOS 11.0, *) {
        }
      }

      fileprivate init() {}
    }

    fileprivate init() {}
  }
  #endif

  #if os(iOS) || os(tvOS)
  struct storyboard: Rswift.Validatable {
    static func validate() throws {
      #if os(iOS) || os(tvOS)
      try launchScreen.validate()
      #endif
      #if os(iOS) || os(tvOS)
      try main.validate()
      #endif
    }

    #if os(iOS) || os(tvOS)
    struct launchScreen: Rswift.StoryboardResourceWithInitialControllerType, Rswift.Validatable {
      typealias InitialController = UIKit.UIViewController

      let bundle = R.hostingBundle
      let name = "LaunchScreen"

      static func validate() throws {
        if UIKit.UIImage(named: "icon", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'icon' is used in storyboard 'LaunchScreen', but couldn't be loaded.") }
        if #available(iOS 11.0, tvOS 11.0, *) {
        }
      }

      fileprivate init() {}
    }
    #endif

    #if os(iOS) || os(tvOS)
    struct main: Rswift.StoryboardResourceType, Rswift.Validatable {
      let bundle = R.hostingBundle
      let name = "Main"

      static func validate() throws {
        if #available(iOS 11.0, tvOS 11.0, *) {
        }
      }

      fileprivate init() {}
    }
    #endif

    fileprivate init() {}
  }
  #endif

  fileprivate init() {}
}
