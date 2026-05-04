# Graph Report - /Users/luowei/projects/libs/LWDynamicFont  (2026-05-04)

## Corpus Check
- Corpus is ~10,588 words - fits in a single context window. You may not need a graph.

## Summary
- 96 nodes · 113 edges · 8 communities detected
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 8|Community 8]]

## God Nodes (most connected - your core abstractions)
1. `LWFontManager` - 37 edges
2. `LWFLog()` - 8 edges
3. `UIFont` - 8 edges
4. `LWAppDelegate` - 7 edges
5. `-registerFont` - 6 edges
6. `FontDownloadObserver` - 5 edges
7. `LWViewController` - 5 edges
8. `DynamicFontModifier` - 4 edges
9. `LWFontDownloadTask` - 3 edges
10. `Font` - 3 edges

## Surprising Connections (you probably didn't know these)
- `-registerFont` --calls--> `LWFLog()`  [EXTRACTED]
  LWDynamicFont/Classes/LWFontManager.m → LWDynamicFont_swift/Classes/LWFontManager.swift

## Communities (13 total, 1 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.1
Nodes (20): LWFontManager, -createDirectoryIfNotExsitPath, -downloadAppleFontWithFontName, -downloadAppleFontWithFvoidontNameshowProgressBlockupdateProgressBlockcompleteBlock, -downloadCustomFontWithFontNameURLString, -downloadCustomFontWithFontNameURLStringshowProgressBlockupdateProgressBlockcompleteBlock, -exsitCustomFontFileWithFontName, -fontDirectoryPath (+12 more)

### Community 1 - "Community 1"
Cohesion: 0.18
Nodes (6): DynamicFontModifier, Font, FontDownloadObserver, View, ObservableObject, ViewModifier

### Community 2 - "Community 2"
Cohesion: 0.23
Nodes (3): DispatchQueue, LWFontManager, UIFont

### Community 3 - "Community 3"
Cohesion: 0.29
Nodes (3): LWFLog(), -registerAllCustomLocalFonts, -registerFont

### Community 4 - "Community 4"
Cohesion: 0.22
Nodes (8): LWAppDelegate, -load, -myApplicationdidFinishLaunchingWithOptions, LWViewController, -btnAction, -loadFontWithFontNamecompleteBlock, -randomFontName, -viewDidLoad

### Community 5 - "Community 5"
Cohesion: 0.22
Nodes (8): LWFontDownloadTask, -taskWithIdentifierfontNamedataTask, NSObject, -lwdf_swizzleClassMethodwithMethod, -lwdf_swizzleMethodwithMethod, UIFont, -load, -myFontWithNamesize

### Community 6 - "Community 6"
Cohesion: 0.25
Nodes (7): LWAppDelegate, -applicationDidBecomeActive, -applicationDidEnterBackground, -applicationdidFinishLaunchingWithOptions, -applicationWillEnterForeground, -applicationWillResignActive, -applicationWillTerminate

## Knowledge Gaps
- **36 isolated node(s):** `LWFontManager`, `-applicationdidFinishLaunchingWithOptions`, `-applicationWillResignActive`, `-applicationDidEnterBackground`, `-applicationWillEnterForeground` (+31 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `LWFontManager` connect `Community 0` to `Community 8`, `Community 3`, `Community 5`, `Community 7`?**
  _High betweenness centrality (0.244) - this node is a cross-community bridge._
- **What connects `LWFontManager`, `-applicationdidFinishLaunchingWithOptions`, `-applicationWillResignActive` to the rest of the system?**
  _36 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._