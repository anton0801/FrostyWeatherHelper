import SwiftUI

struct TemplateSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    let selectedTemplate: (QuickNoteTemplate) -> Void
    
    @State private var showAddTemplate = false
    @State private var newTemplateTitle = ""
    @State private var newTemplateContent = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(dataManager.quickTemplates) { template in
                            TemplateCard(template: template) {
                                selectedTemplate(template)
                                presentationMode.wrappedValue.dismiss()
                            } onDelete: {
                                if template.isCustom {
                                    dataManager.deleteTemplate(template)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.appTextSecondary)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Templates")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddTemplate = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.appAccent)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddTemplate) {
            AddTemplateView()
        }
    }
}

// MARK: - Template Card
struct TemplateCard: View {
    let template: QuickNoteTemplate
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    
                    if template.isCustom {
                        Text("Custom")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.appAccent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.appAccent.opacity(0.2))
                            )
                    }
                }
                
                Spacer()
                
                if template.isCustom {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(.appWarning)
                    }
                }
            }
            
            Text(template.content)
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary)
                .lineLimit(2)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appCard)
        )
        .onTapGesture(perform: onSelect)
    }
}

// MARK: - Add Template View
struct AddTemplateView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    @State private var title = ""
    @State private var content = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    CustomTextField(title: "Template Title", text: $title, placeholder: "e.g., Excellent Conditions")
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Template Content")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.appTextSecondary)
                        
                        TextEditor(text: $content)
                            .font(.system(size: 15))
                            .foregroundColor(.appTextPrimary)
                            .frame(height: 120)
                            .padding(8)
                            .background(Color.appCard)
                            .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.appTextSecondary)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("New Template")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let template = QuickNoteTemplate(
                            id: UUID(),
                            title: title,
                            content: content,
                            isCustom: true
                        )
                        dataManager.addTemplate(template)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.appAccent)
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
}

struct TemplateSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateSelectionView(selectedTemplate: { _ in })
            .environmentObject(DataManager.shared)
    }
}
