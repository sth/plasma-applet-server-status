import QtQuick 2.1
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
	id: configNotifications
	Layout.fillWidth: true
	
	property string cfg_notificationUp: plasmoid.configuration.notificationUp
	property string cfg_notificationDown: plasmoid.configuration.notificationDown
	
	Component.onCompleted: {
		var notificationUp = JSON.parse(cfg_notificationUp);
		var notificationDown = JSON.parse(cfg_notificationDown);
		
		notifyUpAction.currentIndex = notificationUp.action;
		notifyUpCommand.text = notificationUp.extraOptions.command;
		
		notifyDownAction.currentIndex = notificationDown.action;
		notifyDownCommand.text = notificationDown.extraOptions.command;
	}
	
	ColumnLayout {
		anchors.left: parent.left
		anchors.right: parent.right
		
		GroupBox {
			id: notificationUpGroup
			title: "When server goes online"
			visible: true
			
			Layout.fillWidth: true
				
			GridLayout {
				columns: 2
				anchors.fill: parent
				
				PlasmaComponents.Label {
					id: notifyUpActionLabel
					text: i18n("Action:")
					Layout.preferredWidth: notifyUpCommandLabel.implicitWidth
				}
				
				ComboBox {
					id: notifyUpAction
					model: ["Nothing", "System notification", "Command"]
					Layout.fillWidth: true
					Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 20
					onCurrentIndexChanged: updateData()
				}
				
				PlasmaComponents.Label {
					id: notifyUpCommandLabel
					Layout.preferredWidth: notifyUpActionLabel.implicitWidth
					text: i18n("Command:")
					visible: notifyUpAction.currentIndex == 2
				}
				
				TextField {
					id: notifyUpCommand
					Layout.fillWidth: true
					visible: notifyUpAction.currentIndex == 2
					onEditingFinished: updateData()
				}
			}
		}
		
		GroupBox {
			id: notificationDownGroup
			title: "When server goes offline"
			visible: true

			Layout.fillWidth: true
			
			GridLayout {
				columns: 2
				
				anchors.fill: parent
				
				PlasmaComponents.Label {
					id: notifyDownActionLabel
					text: i18n("Action:")
					Layout.preferredWidth: notifyDownCommandLabel.implicitWidth
				}
				
				ComboBox {
					id: notifyDownAction
					model: ["Nothing", "System notification", "Command"]
					Layout.fillWidth: true
					Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 20
					onCurrentIndexChanged: updateData()
				}
				
				PlasmaComponents.Label {
					id: notifyDownCommandLabel
					Layout.preferredWidth: notifyDownActionLabel.implicitWidth
					text: i18n("Command:")
					visible: notifyDownAction.currentIndex == 2
				}
				
				TextField {
					id: notifyDownCommand
					Layout.fillWidth: true
					visible: notifyDownAction.currentIndex == 2
					onEditingFinished: updateData()
				}
			}
		}
	}
	
	function updateData() {
		var notificationUp = {
			action: notifyUpAction.currentIndex,
			extraOptions: {
				command: notifyUpCommand.text
			}
		};
		
		var notificationDown = {
			action: notifyDownAction.currentIndex,
			extraOptions: {
				command: notifyDownCommand.text
			}
		};
		
		cfg_notificationUp = JSON.stringify(notificationUp);
		cfg_notificationDown = JSON.stringify(notificationDown);
	}
}
