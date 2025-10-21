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
    ZStack {
      Color(UIColor.systemBackground)
        .ignoresSafeArea()

      if page.isCover {
        // Cover page design
        VStack(spacing: 24) {
          Spacer()

          if case .single(let imageName) = page.imageLayout {
            Image(imageName)
              .resizable()
              .scaledToFit()
              .frame(maxWidth: 200, maxHeight: 200)
              .shadow(radius: 8)
          }

          Text(page.text)
            .font(.system(size: 32, weight: .bold))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)

          Spacer()
        }
      } else {
        // Regular page with images and text
        ScrollView {
          VStack(alignment: .center, spacing: 24) {
            Spacer()
              .frame(height: 100)

            // Render images based on layout
            switch page.imageLayout {
            case .none:
              EmptyView()

            case .single(let imageName):
              Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 250, maxHeight: 250)
                .shadow(radius: 4)

            case .staggered(let topImage, let bottomImage):
              VStack(spacing: 16) {
                HStack {
                  Spacer()
                    .frame(width: 40)
                  Image(topImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 180, maxHeight: 180)
                    .shadow(radius: 4)
                  Spacer()
                }

                HStack {
                  Spacer()
                  Image(bottomImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 180, maxHeight: 180)
                    .shadow(radius: 4)
                  Spacer()
                    .frame(width: 40)
                }
              }
            }

            // Text below images
            Text(page.text)
              .font(.system(size: 18, weight: .regular))
              .lineSpacing(8)
              .foregroundColor(.primary)
              .padding(.horizontal, 40)
              .padding(.bottom, 80)
          }
          .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)

        // Page number at bottom
        VStack {
          Spacer()
          Text("\(pageNumber)")
            .font(.system(size: 12))
            .foregroundColor(.secondary.opacity(0.5))
            .padding(.bottom, 40)
        }
      }
    }
  }
}
