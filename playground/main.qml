import QtQuick
import QtQuick.Controls
import QtQuick3D
import QtQuick3D.Helpers


ApplicationWindow {
    id: applicationWindow

    property real mult: 30.0
    property real mult2: 100.0/mult
    property real mult3: mult * mult2

    property real cellLengthA: 10.0
    property real cellLengthB: 6.0
    property real cellLengthC: 4.8
    property real cellCilinderThickness: 0.025

    property real axesCilinderThickness: 0.05
    property real axisConeScale: 0.2

    property real atomSize: 0.2

    property int numAtoms: 100

    property var proxy2: {
        'atomsCount': 10,
        'atomsModel': createAtomsModel()
    }

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

        // Repeater is getting really slow with a few hudreds of atoms
        /*
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
        */

        // Random instancing is extremely fast, but it is random...
        RandomInstancing {
            id: randomTable
            instanceCount: proxy.atomsCount
            position: InstanceRange { from: Qt.vector3d(0, 0, 0);
                                      to: Qt.vector3d(cellLengthA * mult, cellLengthA * mult, cellLengthA * mult) }
            color: InstanceRange { from: Qt.rgba(0.1, 0.1, 0.1, 1); to: Qt.rgba(1, 1, 1, 1) }
        }

        // This type allows to have custom parameters and it is much faster then Repeater3D,
        // but still slower then RandomInstancing. Probably because of Qt.createQmlObject. How to fix?
        InstanceList {
            id: atomInstances

            instances: [ InstanceListEntry {color: "red"}, InstanceListEntry {color: "blue"} ]


            /*
            instances: {
                let atoms = []
                for (const atom of proxy.atomsModel) {
                    const listInstance = Qt.createQmlObject('import QtQuick3D; InstanceListEntry {}', parent)
                    listInstance.position = Qt.vector3d(atom.x * cellLengthA * mult,
                                                        atom.y * cellLengthB * mult,
                                                        atom.z * cellLengthC * mult)
                    listInstance.scale = Qt.vector3d(atom.diameter,
                                                     atom.diameter,
                                                     atom.diameter)
                    listInstance.color = atom.color
                    atoms.push(listInstance)
                }
                return atoms
            }
            */



/*
                let atoms = proxy.atomsModel.map(atom => Qt.createQmlObject(`import QtQuick3D
                                                                            InstanceListEntry {
                                                                                position: Qt.vector3d(${atom.x},
                                                                                                      ${atom.y},
                                                                                                      ${atom.z})
                                                                                scale: Qt.vector3d(${atom.diameter},
                                                                                                   ${atom.diameter},
                                                                                                   ${atom.diameter})
                                                                                color: '${atom.color}'
                                                                            }`, parent))

*/





                /*
                let atoms = []
                for (const atom of proxy.atomsModel) {
                    const listInstance = Qt.createQmlObject('import QtQuick3D; InstanceListEntry {}', parent)
                    listInstance.position = Qt.vector3d(atom.x * cellLengthA * mult,
                                                        atom.y * cellLengthB * mult,
                                                        atom.z * cellLengthC * mult)
                    listInstance.scale = Qt.vector3d(atom.diameter,
                                                     atom.diameter,
                                                     atom.diameter)
                    listInstance.color = atom.color
                    atoms.push(listInstance)
                }
                */

                /*
                let atoms = Array.from({length: proxy.atomsModel.length})
                for (let i = 0; i < atoms.length; ++i) {
                    let listInstance = Qt.createQmlObject('import QtQuick3D; InstanceListEntry {}', parent)
                    //const atom = proxy.atomsModel[i]
                    //print('--', JSON.stringify(atoms[i]))
                    listInstance.position = Qt.vector3d(proxy.atomsModel[i].x * cellLengthA * mult,
                                                        proxy.atomsModel[i].y * cellLengthB * mult,
                                                        proxy.atomsModel[i].z * cellLengthC * mult)
                    listInstance.scale = Qt.vector3d(proxy.atomsModel[i].diameter,
                                                     proxy.atomsModel[i].diameter,
                                                     proxy.atomsModel[i].diameter)
                    listInstance.color = proxy.atomsModel[i].color
                    atoms[i] = listInstance
                }
                */

            onInstanceCountChanged: {
                //print('--- onInstanceCountChanged atomInstances', JSON.stringify(atomInstances.children))

            }

            Component.onCompleted: {
                //print('--- Component.onCompleted atomInstances', JSON.stringify(atomInstances.children))
                proxy.atomInstances = atomInstances
                //print('----', JSON.stringify(instances))
                //instances.append({})
            }
        }

        // Atoms
        Model {
            id: atoms
            instancing: InstanceList {
                id: atomsList
                instances: createAtomsList()

            }

            source: "#Sphere"
            materials: [ DefaultMaterial {} ]
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

    // Appbar
    Row {
        property int childrenHeight: 40
        anchors.horizontalCenter: parent.horizontalCenter
        Button {
            height: parent.childrenHeight
            text: 'Generate'
            onClicked: proxy.createAtomsModel()
        }
        TextEdit {
            height: parent.childrenHeight
            verticalAlignment: Text.AlignVCenter
            text: proxy.atomsCount
            color: 'steelblue'
            onTextChanged: proxy.atomsCount = parseInt(text)
        }
        Text {
            height: parent.childrenHeight
            verticalAlignment: Text.AlignVCenter
            text: ' atoms'
        }
    }
    // Appbar

    // Logic

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

    function createAtomsModel() {
        const n = numAtoms
        let out = []
        for (let i = 0; i < n; ++i) {
            out.push({'x': Math.random(),
                      'y': Math.random(),
                      'z': Math.random(),
                      'diameter': 0.2,
                      'color': 'orange'})
        }
        return out
    }

}
