//
//  PageCurlView.swift
//  RosaWriter
//
//  Created by Armin on 10/19/25.
//

import SwiftUI
import UIKit

struct PageCurlView: UIViewControllerRepresentable {
  let pages: [BookPage]
  @Binding var currentPageIndex: Int

  func makeUIViewController(context: Context) -> UIPageViewController {
    let pageViewController = UIPageViewController(
      transitionStyle: .pageCurl,
      navigationOrientation: .horizontal,
      options: nil
    )

    pageViewController.dataSource = context.coordinator
    pageViewController.delegate = context.coordinator

    // Lazily create only the first page controller
    if let firstController = context.coordinator.controller(for: 0) {
      pageViewController.setViewControllers(
        [firstController],
        direction: .forward,
        animated: false
      )
    }

    return pageViewController
  }

  func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
    // Update current page if changed externally
    let currentController = uiViewController.viewControllers?.first
    let currentIndex = context.coordinator.index(of: currentController ?? UIViewController()) ?? 0

    if currentIndex != currentPageIndex {
      let direction: UIPageViewController.NavigationDirection =
        currentPageIndex > currentIndex ? .forward : .reverse
      if let targetController = context.coordinator.controller(for: currentPageIndex) {
        uiViewController.setViewControllers(
          [targetController],
          direction: direction,
          animated: true
        )
      }
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var parent: PageCurlView
    
    // Cache only a limited number of controllers to reduce memory usage
    // Key: page index, Value: the hosting controller for that page
    private var controllerCache: [Int: UIHostingController<PageContentView>] = [:]
    private let maxCacheSize = 5  // Keep at most 5 controllers in memory
    
    init(_ parent: PageCurlView) {
      self.parent = parent
      super.init()
    }
    
    /// Lazily create or retrieve a controller for a given page index
    func controller(for index: Int) -> UIHostingController<PageContentView>? {
      guard index >= 0 && index < parent.pages.count else { return nil }
      
      // Return cached controller if available
      if let cached = controllerCache[index] {
        return cached
      }
      
      // Create new controller
      let page = parent.pages[index]
      let hostingController = UIHostingController(
        rootView: PageContentView(
          page: page,
          pageNumber: index + 1,
          totalPages: parent.pages.count
        )
      )
      
      // Page background: white in light mode, dark gray in dark mode
      hostingController.view.backgroundColor = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
          ? UIColor(white: 0.15, alpha: 1.0)
          : UIColor.white
      }
      
      // Add to cache
      controllerCache[index] = hostingController
      
      // Evict old controllers if cache is too large
      if controllerCache.count > maxCacheSize {
        evictDistantControllers(from: index)
      }
      
      return hostingController
    }
    
    /// Remove controllers that are far from the current page to free memory
    private func evictDistantControllers(from currentIndex: Int) {
      let indicesToKeep = Set((currentIndex - 2)...(currentIndex + 2))
      let indicesToRemove = controllerCache.keys.filter { !indicesToKeep.contains($0) }
      for index in indicesToRemove {
        controllerCache.removeValue(forKey: index)
      }
    }
    
    /// Find the index for a given view controller
    func index(of viewController: UIViewController) -> Int? {
      for (index, controller) in controllerCache where controller === viewController {
        return index
      }
      return nil
    }

    func pageViewController(
      _ pageViewController: UIPageViewController,
      viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
      guard let index = index(of: viewController), index > 0 else {
        return nil
      }
      return controller(for: index - 1)
    }

    func pageViewController(
      _ pageViewController: UIPageViewController,
      viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
      guard let index = index(of: viewController), index < parent.pages.count - 1 else {
        return nil
      }
      return controller(for: index + 1)
    }

    func pageViewController(
      _ pageViewController: UIPageViewController,
      didFinishAnimating finished: Bool,
      previousViewControllers: [UIViewController],
      transitionCompleted completed: Bool
    ) {
      if completed,
        let currentViewController = pageViewController.viewControllers?.first,
        let index = index(of: currentViewController)
      {
        parent.currentPageIndex = index
        // Proactively evict distant controllers after navigation
        evictDistantControllers(from: index)
      }
    }
  }
}

/// A scrollable text view with fade gradients at top/bottom when content overflows
struct FadingScrollText: View {
  let text: String
  let fontSize: CGFloat
  let lineSpacing: CGFloat
  let horizontalPadding: CGFloat
  let topPadding: CGFloat
  let backgroundColor: Color
  
  @State private var hasOverflow = false
  @State private var contentHeight: CGFloat = 0
  @State private var containerHeight: CGFloat = 0
  @State private var scrollOffset: CGFloat = 0
  
  private let fadeHeight: CGFloat = 40
  private let scrollThreshold: CGFloat = 10
  
  /// User has scrolled down from the top
  private var isScrolledFromTop: Bool {
    scrollOffset > scrollThreshold
  }
  
  /// User has scrolled to the bottom
  private var isAtBottom: Bool {
    let maxScroll = max(0, contentHeight - containerHeight)
    return scrollOffset >= maxScroll - scrollThreshold
  }
  
  var body: some View {
    GeometryReader { containerGeometry in
      ZStack {
        ScrollView(showsIndicators: false) {
          Text(text)
            .font(.system(size: fontSize, weight: .regular))
            .lineSpacing(lineSpacing)
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity) // Ensure text takes full width for centering
            .padding(.horizontal, horizontalPadding)
            .padding(.top, topPadding)
            .padding(.bottom, 30) // Extra padding so text isn't hidden by fade
            .frame(minHeight: containerGeometry.size.height) // Allow vertical centering for short text
            .background(
              GeometryReader { textGeometry in
                Color.clear
                  .preference(key: ContentHeightKey.self, value: textGeometry.size.height)
                  .preference(key: ScrollOffsetKey.self, value: -textGeometry.frame(in: .named("scroll")).minY + topPadding)
              }
            )
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ContentHeightKey.self) { height in
          contentHeight = height
          hasOverflow = height > containerGeometry.size.height
        }
        .onPreferenceChange(ScrollOffsetKey.self) { offset in
          scrollOffset = offset
        }
        
        // Top fade gradient - only show when scrolled down
        if hasOverflow && isScrolledFromTop {
          VStack {
            LinearGradient(
              colors: [
                backgroundColor,
                backgroundColor.opacity(0.8),
                backgroundColor.opacity(0)
              ],
              startPoint: .top,
              endPoint: .bottom
            )
            .frame(height: fadeHeight * 0.6)    // reduce top fade height for first line
            .allowsHitTesting(false)
            
            Spacer()
          }
        }
        
        // Bottom fade gradient - only show when not at bottom
        if hasOverflow && !isAtBottom {
          VStack {
            Spacer()
            
            LinearGradient(
              colors: [
                backgroundColor.opacity(0),
                backgroundColor.opacity(0.8),
                backgroundColor
              ],
              startPoint: .top,
              endPoint: .bottom
            )
            .frame(height: fadeHeight)
            .allowsHitTesting(false)
          }
        }
      }
      .onAppear {
        containerHeight = containerGeometry.size.height
      }
      .onChange(of: containerGeometry.size.height) { _, newHeight in
        containerHeight = newHeight
      }
    }
  }
}

private struct ContentHeightKey: PreferenceKey {
  static var defaultValue: CGFloat = 0
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}

private struct ScrollOffsetKey: PreferenceKey {
  static var defaultValue: CGFloat = 0
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}

struct PageContentView: View {
  let page: BookPage
  let pageNumber: Int
  let totalPages: Int
  @Environment(\.colorScheme) private var colorScheme
  
  /// Page background: white in light mode, dark gray in dark mode
  private var pageBackgroundColor: Color {
    colorScheme == .dark ? Color(white: 0.15) : Color.white
  }

  var body: some View {
    GeometryReader { geometry in
      let isLargeDevice = geometry.size.width >= 700  // iPad Mini and larger (744pt in portrait)
      // Increased image size: 85% of width with higher max (was 70% with 250pt max)
      let imageMaxSize =
        isLargeDevice ? min(geometry.size.width * 0.85, 650) : min(geometry.size.width * 0.85, 350)
      let horizontalPadding: CGFloat = isLargeDevice ? 80 : 40
      let fontSize: CGFloat = isLargeDevice ? 26 : 18

      ZStack {
        pageBackgroundColor
          .ignoresSafeArea()

        if page.isCover {
          // Cover page design with book color
          ZStack {
            // Book cover background with gradient
            if let coverColor = page.coverColor {
              LinearGradient(
                colors: [coverColor.lightColor, coverColor.darkColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
              .ignoresSafeArea()
            }

            VStack(spacing: isLargeDevice ? 32 : 24) {
              Spacer()

              if case .single(let imageName) = page.imageLayout {
                Image(imageName)
                  .resizable()
                  .scaledToFit()
                  .frame(maxWidth: imageMaxSize)
                  .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
              }

              Text(page.text)
                .font(.system(size: isLargeDevice ? 52 : 32, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                .padding(.horizontal, horizontalPadding)

              Spacer()
            }
          }
        } else if case .none = page.imageLayout {
          // Text-only page: center the text vertically
          VStack(spacing: 0) {
            Spacer()
            
            FadingScrollText(
              text: page.text,
              fontSize: fontSize,
              lineSpacing: isLargeDevice ? 10 : 8,
              horizontalPadding: horizontalPadding,
              topPadding: 0,
              backgroundColor: pageBackgroundColor
            )
            .frame(maxHeight: geometry.size.height * 0.7)
            
            Spacer()

            // Page number at bottom
            Text("\(pageNumber)")
              .font(.system(size: isLargeDevice ? 14 : 12))
              .foregroundColor(.secondary.opacity(0.5))
              .padding(.bottom, isLargeDevice ? 30 : 20)
          }
        } else {
          // Regular page with images and text
          VStack(spacing: 0) {
            Spacer(minLength: isLargeDevice ? 50 : 20)
            // Image Section - Top 60%
            VStack {
              Spacer()
              // Render images based on layout
              switch page.imageLayout {
              case .none:
                EmptyView()

              case .single(let imageName):
                Image(imageName)
                  .resizable()
                  .scaledToFit()
                  .frame(maxWidth: imageMaxSize)
                  .shadow(radius: 4)

              case .staggered(let topImage, let bottomImage):
                let isEvenPage = pageNumber % 2 == 0
                
                // Resolve sizes
                let topSize = StoryAssets.size(forImageName: topImage)
                let bottomSize = StoryAssets.size(forImageName: bottomImage)
                
                // Calculate widths based on imageMaxSize (flexible layout)
                // Large: 0.7, Small: 0.4
                let topWidth = imageMaxSize * (topSize == .large ? 0.7 : 0.4)
                let bottomWidth = imageMaxSize * (bottomSize == .large ? 0.7 : 0.4)

                VStack(spacing: isLargeDevice ? 8 : 4) {
                  // Top image
                  HStack {
                    if !isEvenPage { Spacer() }
                    Image(topImage)
                      .resizable()
                      .scaledToFit()
                      .frame(width: topWidth)
                      .padding(12)
                      .scaleEffect(x: isEvenPage ? -1 : 1, y: 1, anchor: .center)
                      .shadow(radius: 4)
                    if isEvenPage { Spacer() }
                  }
                  .padding(.horizontal, 20)

                  // Bottom image
                  HStack {
                    if isEvenPage { Spacer() }
                    Image(bottomImage)
                      .resizable()
                      .scaledToFit()
                      .frame(width: bottomWidth)
                      .padding(12)
                      .scaleEffect(x: isEvenPage ? 1 : -1, y: 1, anchor: .center)
                      .shadow(radius: 4)
                    if !isEvenPage { Spacer() }
                  }
                  .padding(.horizontal, 20)
                }
              }
              Spacer()
            }
            .frame(height: geometry.size.height * 0.60)
            
            // Text Section - Bottom rest with fade indicator
            FadingScrollText(
              text: page.text,
              fontSize: fontSize,
              lineSpacing: isLargeDevice ? 10 : 8,
              horizontalPadding: horizontalPadding,
              topPadding: 20,
              backgroundColor: pageBackgroundColor
            )
            
            Spacer(minLength: 10)

            // Page number at bottom
            Text("\(pageNumber)")
              .font(.system(size: isLargeDevice ? 14 : 12))
              .foregroundColor(.secondary.opacity(0.5))
              .padding(.bottom, isLargeDevice ? 30 : 20)
          }
        }
      }
    }
  }
}
