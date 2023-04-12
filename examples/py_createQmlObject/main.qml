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
    property real cellCylinderThickness: 0.025

    property real axesCylinderThickness: 0.05
    property real axisConeScale: 0.2

    property real magmomCylinderThickness: 0.05
    property real magmomConeScale: 0.4

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
                scale: Qt.vector3d(cellCylinderThickness,
                                   cell.model[index].len / mult2,
                                   cellCylinderThickness)
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
                    scale: Qt.vector3d(axesCylinderThickness,
                                       axes.model[index].len / mult2,
                                       axesCylinderThickness)
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
        Model {
            instancing: InstanceList {
                id: atomsList
                instances: createAtomsList()
            }
            source: "#Sphere"
            materials: [ DefaultMaterial {} ]
        }
        // Atoms

        // Magnetic moments
        Node {
            Model {
                instancing: InstanceList {
                    id: cylindersList
                    instances: createCylindersList()
                }
                source: "#Cylinder"
                materials: [ DefaultMaterial {} ]
            }

            Model {
                instancing: InstanceList {
                    id: conesList
                    instances: createConesList()
                }
                source: "#Cone"
                materials: [ DefaultMaterial {} ]
            }
        }
        // Magnetic moments

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
                proxy.createAtomsModel()
            }
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

    // Logic

    // Quick-and-dirty solution of creating list of atoms. We probably need a custom python implementation
    // similar to, e.g., C++ in https://doc.qt.io/qt-6/qtquick3d-custominstancing-example.html
    // Still works much faster compared to Repeater3D
    function createAtomsList() {
        let atoms = []
        for (const atom of proxy.atomsModel) {
            const instance = Qt.createQmlObject('import QtQuick3D; InstanceListEntry {}', atomsList)
            instance.position = Qt.vector3d(atom.x * cellLengthA * mult,
                                            atom.y * cellLengthB * mult,
                                            atom.z * cellLengthC * mult)
            instance.scale = Qt.vector3d(atom.diameter,
                                         atom.diameter,
                                         atom.diameter)
            instance.color = atom.color
            atoms.push(instance)
        }
        return atoms
    }

    function createCylindersList() {
        let cylinders = []
        for (const atom of proxy.atomsModel) {
            const instance = Qt.createQmlObject('import QtQuick3D; InstanceListEntry {}', atomsList)
            instance.position = Qt.vector3d(atom.x * cellLengthA * mult,
                                            atom.y * cellLengthB * mult,
                                            atom.z * cellLengthC * mult)
            instance.eulerRotation = Qt.vector3d(atom.mrotx,
                                                 atom.mroty,
                                                 atom.mrotz)
            instance.scale = Qt.vector3d(magmomCylinderThickness,
                                         atom.mlen / mult2,
                                         magmomCylinderThickness)
            instance.color = atom.color
            cylinders.push(instance)
        }
        return cylinders
    }

    function createConesList() {
        let cones = []
        for (const atom of proxy.atomsModel) {
            const instance = Qt.createQmlObject('import QtQuick3D; InstanceListEntry {}', atomsList)
            instance.position = Qt.vector3d(atom.x * cellLengthA * mult,
                                            atom.y * cellLengthB * mult,
                                            atom.z * cellLengthC * mult)
            instance.eulerRotation = Qt.vector3d(atom.mrotx,
                                                 atom.mroty,
                                                 atom.mrotz)
            instance.scale = Qt.vector3d(magmomConeScale,
                                         magmomConeScale,
                                         magmomConeScale)
            instance.color = atom.color
            cones.push(instance)
        }
        return cones
    }

}

// Links
// Examples: https://doc.qt.io/qt-6/quick3d-examples.html
// Picking example: https://doc.qt.io/qt-6/qtquick3d-picking-main-qml.html
