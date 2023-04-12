import QtQuick
import QtQuick.Controls
import QtQuick3D
import QtQuick3D.Helpers


ApplicationWindow {
    id: applicationWindow

    property real mult: 30.0
    property real mult2: 100.0 / mult
    property real mult3: mult * mult2

    property real cellLengthA: 10.0
    property real cellLengthB: 6.0
    property real cellLengthC: 4.8
    property real cellCilinderThickness: 0.025

    property real axesCilinderThickness: 0.05
    property real axisConeScale: 0.2

    visible: true

    width: minimumWidth
    height: minimumHeight
    minimumWidth: 650
    minimumHeight: 500

    // View3D
    View3D {
        id: view

        width: applicationWindow.width
        height: applicationWindow.height

        environment: SceneEnvironment {
            clearColor: "white"
            backgroundMode: SceneEnvironment.Color
        }

        camera: cameraNode

        // Node
        Node {
            id: originNode
            position: Qt.vector3d(cellLengthA * mult / 2, cellLengthB * mult / 2, cellLengthC * mult / 2)

            PerspectiveCamera {
                id: cameraNode
                position: Qt.vector3d(0, 0, 500) // position translation in local coordinate
            }
        }
        // Node

        // Rotation controller
        OrbitCameraController {
            anchors.fill: parent
            origin: originNode
            camera: cameraNode
        }
        // Rotation controller

        // Light
        DirectionalLight {
            eulerRotation.x: -30
            eulerRotation.y: 30
        }
        // Light

        // Unit cell
        Repeater3D {
            id: cell
            model: [
                {"x": 0.5, "y": 0, "z": 0, "rotx": 0, "roty": 0, "rotz": -90, "len": cellLengthA},
                {"x": 0.5, "y": 1, "z": 0, "rotx": 0, "roty": 0, "rotz": -90, "len": cellLengthA},
                {"x": 0.5, "y": 0, "z": 1, "rotx": 0, "roty": 0, "rotz": -90, "len": cellLengthA},
                {"x": 0.5, "y": 1, "z": 1, "rotx": 0, "roty": 0, "rotz": -90, "len": cellLengthA},
                // y
                {"x": 0, "y": 0.5, "z": 0, "rotx": 0, "roty": 0, "rotz": 0, "len": cellLengthB},
                {"x": 1, "y": 0.5, "z": 0, "rotx": 0, "roty": 0, "rotz": 0, "len": cellLengthB},
                {"x": 0, "y": 0.5, "z": 1, "rotx": 0, "roty": 0, "rotz": 0, "len": cellLengthB},
                {"x": 1, "y": 0.5, "z": 1, "rotx": 0, "roty": 0, "rotz": 0, "len": cellLengthB},
                // z
                {"x": 0, "y": 0, "z": 0.5, "rotx": 0, "roty": 90, "rotz": 90, "len": cellLengthC},
                {"x": 1, "y": 0, "z": 0.5, "rotx": 0, "roty": 90, "rotz": 90, "len": cellLengthC},
                {"x": 0, "y": 1, "z": 0.5, "rotx": 0, "roty": 90, "rotz": 90, "len": cellLengthC},
                {"x": 1, "y": 1, "z": 0.5, "rotx": 0, "roty": 90, "rotz": 90, "len": cellLengthC},
            ]
            Model {
                source: "#Cylinder"
                position: Qt.vector3d(cell.model[index].x * cellLengthA * mult,
                                      cell.model[index].y * cellLengthB * mult,
                                      cell.model[index].z * cellLengthC * mult)
                eulerRotation: Qt.vector3d(cell.model[index].rotx,
                                           cell.model[index].roty,
                                           cell.model[index].rotz)
                scale: Qt.vector3d(cellCilinderThickness,
                                   cell.model[index].len / mult2,
                                   cellCilinderThickness)
                materials: [ DefaultMaterial { diffuseColor: "grey" } ]
            }
        }
        // Unit cell

        // Axes
        Repeater3D {
            id: axes
            model: [
                {"x": 0.5, "y": 0, "z": 0, "rotx": 0, "roty": 0, "rotz": -90, "len": cellLengthA, "color": "red"},
                {"x": 0, "y": 0.5, "z": 0, "rotx": 0, "roty": 0, "rotz": 0, "len": cellLengthB, "color": "green"},
                {"x": 0, "y": 0, "z": 0.5, "rotx": 0, "roty": 90, "rotz": 90, "len": cellLengthC, "color": "blue"},
            ]
            Node {
                Model {
                    source: "#Cylinder"
                    position: Qt.vector3d(axes.model[index].x * cellLengthA * mult,
                                          axes.model[index].y * cellLengthB * mult,
                                          axes.model[index].z * cellLengthC * mult)
                    eulerRotation: Qt.vector3d(axes.model[index].rotx,
                                               axes.model[index].roty,
                                               axes.model[index].rotz)
                    scale: Qt.vector3d(axesCilinderThickness,
                                       axes.model[index].len / mult2,
                                       axesCilinderThickness)
                    materials: [ DefaultMaterial { diffuseColor: axes.model[index].color } ]

                }
                Model {
                    source: "#Cone"
                    position: Qt.vector3d(axes.model[index].x * (cellLengthA * mult - axisConeScale * mult3) * 2,
                                          axes.model[index].y * (cellLengthB * mult - axisConeScale * mult3) * 2,
                                          axes.model[index].z * (cellLengthC * mult - axisConeScale * mult3) * 2)
                    eulerRotation: Qt.vector3d(axes.model[index].rotx,
                                               axes.model[index].roty,
                                               axes.model[index].rotz)
                    scale: Qt.vector3d(axisConeScale, axisConeScale, axisConeScale)
                    materials: [ DefaultMaterial { diffuseColor: axes.model[index].color } ]
                }
            }
        }
        // Axes

        // Atoms
        Repeater3D {
            id: atoms
            model: proxy.atomsModel
            Model {
                source: "#Sphere"
                position: Qt.vector3d(atoms.model[index].x * cellLengthA * mult,
                                      atoms.model[index].y * cellLengthB * mult,
                                      atoms.model[index].z * cellLengthC * mult)
                scale: Qt.vector3d(atoms.model[index].diameter,
                                   atoms.model[index].diameter,
                                   atoms.model[index].diameter)
                materials: [ DefaultMaterial { diffuseColor: atoms.model[index].color } ]
            }
        }
        // Atoms

        // Mouse area
        MouseArea {
            anchors.fill: view
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    print('Left mouse button clicked')
                }
                else {
                    print('Right mouse button clicked')
                }
            }
        }
        // Mouse area

    }
    // View3D

    // Top bar
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        Button {
            anchors.verticalCenter: parent.verticalCenter
            text: 'Generate'
            onClicked: {
                atomsCountField.focus = false
                proxy.atomsCount = atomsCountField.text !== '' ? atomsCountField.text : 1
                proxy.createAtomsModel() }
        }
        TextField {
            id: atomsCountField
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: TextInput.AlignRight
            color: 'steelblue'
            font.bold: true
            validator: RegularExpressionValidator { regularExpression: /^[1-9][0-9]{2}|[1-4][0-9]{3}|5000/ }
            text: proxy.atomsCount
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            text: ' atoms'
        }
    }
    // Top bar

}

