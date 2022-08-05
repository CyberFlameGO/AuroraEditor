//
//  WorkspaceCodeFileEditor.swift
//  AuroraEditor
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI
import UniformTypeIdentifiers

struct WorkspaceCodeFileView: View {
    var windowController: NSWindowController

    @ObservedObject
    var workspace: WorkspaceDocument

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @State
    private var font: NSFont = {
        let size = AppPreferencesModel.shared.preferences.textEditing.font.size
        let name = AppPreferencesModel.shared.preferences.textEditing.font.name
        return NSFont(name: name, size: Double(size)) ?? NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
    }()

    @ViewBuilder
    var codeView: some View {
        ZStack {
            if let item = workspace.selectionState.openFileItems.first(where: { file in
                if file.tabID == workspace.selectionState.selectedId {
                    Log.info("Item loaded is: \(file.url)")
                }

                return file.tabID == workspace.selectionState.selectedId
            }) {
                if let fileItem = workspace.selectionState.openedCodeFiles[item] {
                    if fileItem.typeOfFile == .image {
                        imageFileView(fileItem, for: item)
                    } else {
                        // TODO: Disable editor V1
                        codeFileView(fileItem, for: item)

                        // TODO: Test editor V2
//                        aeCodeView(fileItem, for: item)
                    }
                }
            } else {
                Text("No Editor")
                    .font(.system(size: 17))
                    .foregroundColor(.secondary)
                    .frame(minHeight: 0)
                    .clipped()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func codeFileView(
        _ codeFile: CodeFileDocument,
        for item: WorkspaceClient.FileItem
    ) -> some View {
        // TODO: Wesley - implement new editor.
        CodeFileView(codeFile: codeFile)
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(spacing: 0) {
                    BreadcrumbsView(file: item, tappedOpenFile: workspace.openTab(item:))
                    Divider()
                }
            }
    }

    @ViewBuilder
    private func aeCodeView(
        _ codeFile: CodeFileDocument,
        for item: WorkspaceClient.FileItem
    ) -> some View {
        // TODO: Wesley - implement new editor.
        AECodeView(codeFile: codeFile)
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(spacing: 0) {
                    BreadcrumbsView(file: item, tappedOpenFile: workspace.openTab(item:))
                    Divider()
                }
            }
    }

    @ViewBuilder
    private func imageFileView(
        _ otherFile: CodeFileDocument,
        for item: WorkspaceClient.FileItem
    ) -> some View {
        ZStack {
            if let url = otherFile.previewItemURL,
               let image = NSImage(contentsOf: url),
               otherFile.typeOfFile == .image {
                GeometryReader { proxy in
                    if image.size.width > proxy.size.width || image.size.height > proxy.size.height {
                        OtherFileView(otherFile)
                    } else {
                        OtherFileView(otherFile)
                            .frame(width: image.size.width, height: image.size.height)
                            .position(x: proxy.frame(in: .local).midX, y: proxy.frame(in: .local).midY)
                    }
                }
            } else {
                OtherFileView(otherFile)
            }
        }.safeAreaInset(edge: .top, spacing: 0) {
            VStack(spacing: 0) {
                BreadcrumbsView(file: item, tappedOpenFile: workspace.openTab(item:))
                Divider()
            }
        }
    }

    var body: some View {
        codeView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: AECodeView
public struct AECodeView: View {
    @ObservedObject
    private var codeFile: CodeFileDocument

    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    @Environment(\.colorScheme)
    private var colorScheme

    private let editable: Bool

    public init(codeFile: CodeFileDocument, editable: Bool = true) {
        self.codeFile = codeFile
        self.editable = editable
    }

    @State
    private var selectedTheme = ThemeModel.shared.selectedTheme ?? ThemeModel.shared.themes.first!

    @State
    private var font: NSFont = {
        let size = AppPreferencesModel.shared.preferences.textEditing.font.size
        let name = AppPreferencesModel.shared.preferences.textEditing.font.name
        return NSFont(name: name, size: Double(size)) ?? NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
    }()

    public var body: some View {
        AuroraEditorTextView(
            $codeFile.content,
            font: $font,
            tabWidth: $prefs.preferences.textEditing.defaultTabWidth,
            lineHeight: .constant(1.2)
        )
        .id(codeFile.fileURL)
        .background(selectedTheme.editor.background.swiftColor)
        .disabled(!editable)
        .frame(maxHeight: .infinity)
        .onChange(of: ThemeModel.shared.selectedTheme) { newValue in
            guard let theme = newValue else { return }
            self.selectedTheme = theme
        }
        .onChange(of: prefs.preferences.textEditing.font) { _ in
            font = NSFont(
                name: prefs.preferences.textEditing.font.name,
                size: Double(prefs.preferences.textEditing.font.size)
            ) ?? .monospacedSystemFont(ofSize: 12, weight: .regular)
        }
    }
}