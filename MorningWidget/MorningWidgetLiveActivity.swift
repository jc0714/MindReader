//
//  MorningWidgetLiveActivity.swift
//  MorningWidget
//
//  Created by J oyce on 2024/10/6.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MorningWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct MorningWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MorningWidgetAttributes.self) { context in
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

extension MorningWidgetAttributes {
    fileprivate static var preview: MorningWidgetAttributes {
        MorningWidgetAttributes(name: "World")
    }
}

extension MorningWidgetAttributes.ContentState {
    fileprivate static var smiley: MorningWidgetAttributes.ContentState {
        MorningWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: MorningWidgetAttributes.ContentState {
         MorningWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: MorningWidgetAttributes.preview) {
   MorningWidgetLiveActivity()
} contentStates: {
    MorningWidgetAttributes.ContentState.smiley
    MorningWidgetAttributes.ContentState.starEyes
}
