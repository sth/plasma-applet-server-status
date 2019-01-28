import QtQuick 2.1
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import ".."

ColumnLayout {
	id: configGeneral
	
	property string cfg_servers: plasmoid.configuration.servers
	
	ServersModel {
		id: serversModel
	}

	Component.onCompleted: {
		serversModel.clear();
		
		var servers = JSON.parse(cfg_servers);
		
		for(var i = 0; i < servers.length; i++) {
			serversModel.append(servers[i]);
		}
	}

	RowLayout {
		TableView {
			id: serversTable
			model: serversModel
			
			Layout.fillWidth: true
			Layout.fillHeight: true
			
			TableViewColumn {
				role: "active"
				width: 20
				delegate: CheckBox {
					checked: model.active
					onClicked: {
						model.active = checked;
						
						cfg_servers = JSON.stringify(getServersArray());
					}
				}
			}
			
			TableViewColumn {
				role: "name"
				title: "Name"
			}
			
			onDoubleClicked: {
				editServer();
			}
		}
		
		ColumnLayout {
			id: buttonsColumn
			
			Layout.fillWidth: false
			Layout.alignment: Qt.AlignTop
			
			Button {
				text: "Add..."
				iconName: "list-add"

				Layout.fillWidth: true
				
				onClicked: {
					addServer();
				}
			}
			
			Button {
				text: "Edit"
				iconName: "edit-entry"
				enabled: serversTable.currentRow != -1

				Layout.fillWidth: true
				
				onClicked: {
					editServer();
				}
			}
			
			Button {
				text: "Remove"
				iconName: "list-remove"
				enabled: serversTable.currentRow != -1

				Layout.fillWidth: true
				
				onClicked: {
					if(serversTable.currentRow == -1) return;
					
					var row = serversTable.currentRow;
					serversTable.currentRow = -1;
					serversTable.selection.clear()
					serversTable.model.remove(row);
					
					cfg_servers = JSON.stringify(getServersArray());
				}
			}
			
			Button {
				text: i18n("Move up")
				iconName: "go-up"
				enabled: {
					return serversTable.currentRow > 0
				}

				Layout.fillWidth: true
				
				onClicked: {
					if(serversTable.currentRow < 1) return;

					serversTable.model.move(serversTable.currentRow, serversTable.currentRow - 1, 1);
					serversTable.selection.clear();
					serversTable.selection.select(serversTable.currentRow - 1);
				}
			}
			
			Button {
				text: i18n("Move down")
				iconName: "go-down"
				enabled: {
					return serversTable.currentRow != -1 && serversTable.currentRow < serversTable.model.count - 1;
				}

				Layout.fillWidth: true
				
				onClicked: {
					if(serversTable.currentRow == -1 || serversTable.currentRow >= serversTable.model.count - 1) return;
					
					serversTable.model.move(serversTable.currentRow, serversTable.currentRow + 1, 1);
					serversTable.selection.clear();
					serversTable.selection.select(serversTable.currentRow + 1);
				}
			}
		}
	}
	
	
	Dialog {
		id: serverDialog
		visible: false
		title: "Server"
		standardButtons: StandardButton.Save | StandardButton.Cancel

		property int serverIndex
		
		onAccepted: {
			var itemObject = {
				name: serverName.text,
				hostname: serverHostname.text,
				refreshRate: serverRefreshRate.value,
				method: serverMethod.currentIndex,
				active: serverActive.checked,
				extraOptions: {
					command: serverCommand.text
				}
			};
			
			if(serverIndex == -1) {
				serversModel.append(itemObject);
			} else {
				serversModel.set(serverIndex, itemObject);
			}
			
			cfg_servers = JSON.stringify(getServersArray());
		}

		ColumnLayout {
			anchors.fill: parent

			GridLayout {
				columns: 2
				Layout.alignment: Qt.AlignTop
				
				Label {
					text: "Name:"
				}
				
				TextField {
					id: serverName
					Layout.fillWidth: true
					Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 40
				}
				
				
				Label {
					text: "Host name:"
				}
				
				TextField {
					id: serverHostname
					Layout.fillWidth: true
					Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 40
				}
				
				
				Label {
					text: i18n("Refresh rate:")
				}
				
				SpinBox {
					id: serverRefreshRate
					suffix: i18n(" seconds")
					minimumValue: 1
					maximumValue: 3600
				}
				
				
				Label {
					text: i18n("Check method:")
				}
				
				ComboBox {
					id: serverMethod
					model: ["Ping", "PingV6", "HTTP 200 OK", "Command"]
					Layout.fillWidth: true
					Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 15
				}
				
				
				Label {
					text: ""
				}
				
				CheckBox {
					id: serverActive
					text: i18n("Active")
				}


				Label {
					text: "Command:"
					visible: serverMethod.currentIndex == 3
					width: parent.width
				}
				
				ColumnLayout {
					visible: serverMethod.currentIndex == 3

					TextField {
						id: serverCommand
						Layout.fillWidth: true
						Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 40
					}
					Label {
						Layout.fillWidth: true
						wrapMode: Text.WordWrap
						text: i18n("Use %hostname% to pass server's hostname as an argument or option to the executable.")
					}
				}
			}
		}
	}
	
	function addServer() {
		serverDialog.serverIndex = -1;
		
		serverName.text = ""
		serverHostname.text = ""
		serverRefreshRate.value = 60
		serverMethod.currentIndex = 0
		serverActive.checked = true
		
		serverDialog.visible = true;
		serverName.focus = true;
	}
	
	function editServer() {
		serverDialog.serverIndex = serversTable.currentRow;
		
		var server = serversModel.get(serversTable.currentRow)
		serverName.text = server.name
		serverHostname.text = server.hostname
		serverRefreshRate.value = server.refreshRate
		serverMethod.currentIndex = server.method
		serverActive.checked = server.active
		
		serverDialog.visible = true;
		serverName.focus = true;
	}
	
	function getServersArray() {
		var serversArray = [];
		
		for(var i = 0; i < serversModel.count; i++) {
			serversArray.push(serversModel.get(i));
		}
		
		return serversArray;
	}
}
