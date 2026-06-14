//
//  KimigatsukuruWidgetLiveActivity.swift
//  KimigatsukuruWidget
//
//  Created by macbook on 2026/06/14.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct KimigatsukuruWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct KimigatsukuruWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: KimigatsukuruWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension KimigatsukuruWidgetAttributes {
    fileprivate static var preview: KimigatsukuruWidgetAttributes {
        KimigatsukuruWidgetAttributes(name: "World")
    }
}

extension KimigatsukuruWidgetAttributes.ContentState {
    fileprivate static var smiley: KimigatsukuruWidgetAttributes.ContentState {
        KimigatsukuruWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: KimigatsukuruWidgetAttributes.ContentState {
         KimigatsukuruWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: KimigatsukuruWidgetAttributes.preview) {
   KimigatsukuruWidgetLiveActivity()
} contentStates: {
    KimigatsukuruWidgetAttributes.ContentState.smiley
    KimigatsukuruWidgetAttributes.ContentState.starEyes
}
