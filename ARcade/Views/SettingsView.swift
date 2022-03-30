//
//  SettingsView.swift
//  ARcade
//
//  Created by Daniel Marks on 04/03/2022.
//

import SwiftUI
import ARKit

enum Setting: String, CaseIterable {
    
    case peopleOcclusion = "People Occlusion"
    case objectOcclusion = "Object Occlusion"
    case lidarDebug = "LiDAR"
    case multiuser = "Multiuser"
    
    var systemIconName: String {
        get {
            switch self {
            case .peopleOcclusion:
                return "person"
            case .objectOcclusion:
                return "cube.box.fill"
            case .lidarDebug:
                return "light.min"
            case .multiuser:
                return "person.2"
            }
        }
    }
}

struct SettingsView: View {
    
    @Binding var isSettingsActive: Bool
    
    var body: some View {
        NavigationView {
            SettingsList()
                .navigationBarTitle(Text("Settings"))
                .navigationBarItems(trailing:
                    Button(action: {
                        isSettingsActive = false
                    }, label: {
                        Text("Done")
                            .bold()
                            .foregroundColor(Color(.systemGray))
                    })
                )
        }
    }
}

struct SettingsList: View {
    
    @EnvironmentObject var sessionSettings: SessionManager
    
    var body: some View {
        VStack {
            if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
                SettingToggleRow(setting: .peopleOcclusion, isOn: $sessionSettings.isPeopleOcclusionEnabled)
            }
            
            SettingToggleRow(setting: .objectOcclusion, isOn: $sessionSettings.isObjectOcclusionEnabled)
            
            SettingToggleRow(setting: .lidarDebug, isOn: $sessionSettings.isLidarDebugEnabled)
            
            SettingToggleRow(setting: .multiuser, isOn: $sessionSettings.isMultiuserEnabled)
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

struct SettingToggleRow: View {
    
    let setting: Setting
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: setting.systemIconName)
                .font(.system(size: 35))
                .foregroundColor(isOn ? .green : Color(UIColor.secondaryLabel))
                .frame(height: 35)
                .padding(.vertical, 10)
                .padding(.trailing, 10)
            
            Text(setting.rawValue)
                .font(.system(size: 17, weight: .medium, design: .default))
                .foregroundColor(isOn ? .green : Color(UIColor.secondaryLabel))
            
            Spacer()
        }
        .padding(.horizontal)
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(8.0)
        .onTapGesture {
            Logger.log(type: .debug, message: "\(setting.rawValue) tapped")
            isOn.toggle()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isSettingsActive: .constant(true))
    }
}
