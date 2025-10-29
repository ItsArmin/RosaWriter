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

    if let firstPage = context.coordinator.controllers.first {
      pageViewController.setViewControllers(
        [firstPage],
        direction: .forward,
        animated: false
      )
    }

    return pageViewController
  }

  func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
    // Update current page if changed externally
    let currentController = uiViewController.viewControllers?.first
    let currentIndex =
      context.coordinator.controllers.firstIndex(where: { $0 === currentController }) ?? 0

    if currentIndex != currentPageIndex {
      let direction: UIPageViewController.NavigationDirection =
        currentPageIndex > currentIndex ? .forward : .reverse
      if currentPageIndex < context.coordinator.controllers.count {
        uiViewController.setViewControllers(
          [context.coordinator.controllers[currentPageIndex]],
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
    var controllers: [UIHostingController<PageContentView>] = []

    init(_ parent: PageCurlView) {
      self.parent = parent
      super.init()

      // Create a UIHostingController for each page
      controllers = parent.pages.enumerated().map { index, page in
        let hostingController = UIHostingController(
          rootView: PageContentView(
            page: page,
            pageNumber: index + 1,
            totalPages: parent.pages.count
          )
        )
        hostingController.view.backgroundColor = .systemBackground
        return hostingController
      }
    }

    func pageViewController(
      _ pageViewController: UIPageViewController,
      viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
      guard
        let index = controllers.firstIndex(
          of: viewController as! UIHostingController<PageContentView>),
        index > 0
      else {
        return nil
      }
      return controllers[index - 1]
    }

    func pageViewController(
      _ pageViewController: UIPageViewController,
      viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
      guard
        let index = controllers.firstIndex(
          of: viewController as! UIHostingController<PageContentView>),
        index < controllers.count - 1
      else {
        return nil
      }
      return controllers[index + 1]
    }

    func pageViewController(
      _ pageViewController: UIPageViewController,
      didFinishAnimating finished: Bool,
      previousViewControllers: [UIViewController],
      transitionCompleted completed: Bool
    ) {
      if completed,
        let currentViewController = pageViewController.viewControllers?.first,
        let index = controllers.firstIndex(
          of: currentViewController as! UIHostingController<PageContentView>)
      {
        parent.currentPageIndex = index
      }
    }
  }
}

struct PageContentView: View {
  let page: BookPage
  let pageNumber: Int
  let totalPages: Int

  var body: some View {
    GeometryReader { geometry in
      let isLargeDevice = geometry.size.width >= 700  // iPad Mini and larger (744pt in portrait)
      let imageMaxSize =
        isLargeDevice ? min(geometry.size.width * 0.8, 650) : min(geometry.size.width * 0.7, 250)
      let horizontalPadding: CGFloat = isLargeDevice ? 80 : 40
      let fontSize: CGFloat = isLargeDevice ? 26 : 18

      ZStack {
        Color(UIColor.systemBackground)
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
                  .frame(maxWidth: imageMaxSize, maxHeight: imageMaxSize)
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
        } else {
          // Regular page with images and text - centered content
          VStack {
            Spacer()
            
            VStack(alignment: .center, spacing: isLargeDevice ? 32 : 24) {
              // Render images based on layout
              switch page.imageLayout {
              case .none:
                EmptyView()

              case .single(let imageName):
                Image(imageName)
                  .resizable()
                  .scaledToFit()
                  .frame(maxWidth: imageMaxSize, maxHeight: imageMaxSize)
                  .shadow(radius: 4)

              case .staggered(let topImage, let bottomImage):
                VStack(spacing: isLargeDevice ? 24 : 16) {
                  HStack {
                    Spacer()
                      .frame(width: isLargeDevice ? 60 : 40)
                    Image(topImage)
                      .resizable()
                      .scaledToFit()
                      .frame(maxWidth: imageMaxSize * 0.7, maxHeight: imageMaxSize * 0.7)
                      .shadow(radius: 4)
                      .scaleEffect(x: -1, y: 1)
                    Spacer()
                  }

                  HStack {
                    Spacer()
                    Image(bottomImage)
                      .resizable()
                      .scaledToFit()
                      .frame(maxWidth: imageMaxSize * 0.7, maxHeight: imageMaxSize * 0.7)
                      .shadow(radius: 4)
                    Spacer()
                      .frame(width: isLargeDevice ? 60 : 40)
                  }
                }
              }

              // Text below images
              Text(page.text)
                .font(.system(size: fontSize, weight: .regular))
                .lineSpacing(isLargeDevice ? 10 : 8)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, horizontalPadding)
            }
            .frame(maxWidth: isLargeDevice ? 900 : .infinity)

            Spacer()

            // Page number at bottom
            Text("\(pageNumber)")
              .font(.system(size: isLargeDevice ? 14 : 12))
              .foregroundColor(.secondary.opacity(0.5))
              .padding(.bottom, 40)
          }
        }
      }
    }
  }
}
