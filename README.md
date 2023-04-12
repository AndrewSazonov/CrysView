## About

**CrysView** is a simple crystal structure visualisation component based on the [Qt Quick 3D](https://doc.qt.io/qt-6/qtquick3d-index.html) framework and written in [Qt QML](https://doc.qt.io/qt-6/qtqml-index.html). It is planned to use the Python package [crysvue](https://github.com/wardsimon/crysvue) as a backend for calculating the atomic positions, their radii, colour, etc.

## Usage

* Create virtual environment and activate it (*optional*)
  ```
  python -m venv .venv
  source .venv/bin/activate
  ```
* Upgrade pip (*optional*)
  ```
  pip install --upgrade pip
  ```
* Install Python dependencies
  ```
  pip install pyside6
  pip install git+https://github.com/wardsimon/crysvue.git
  ```
* Clone repo
  ```
  git clone https://github.com/AndrewSazonov/CrysView.git
  ```
* Run example
  ```
  cd CrysView
  python examples/EXAMPLE_NAME/main.py
  ```

## Examples

#### With logic defined in the Python backend

###### **py_Repeater3D**

The most naive implementation using `Repeater3D` for displaying multiple atoms. Works fine for up to about 100 of atoms.
```
Repeater3D {
  id: atoms
  model: proxy.atomsModel
  Model {
    source: "#Sphere"
    position: Qt.vector3d(atoms.model[index].x,
                          atoms.model[index].y,
                          atoms.model[index].z)
    scale: Qt.vector3d(atoms.model[index].diameter,
                       atoms.model[index].diameter,
                       atoms.model[index].diameter)
    materials: [ DefaultMaterial { diffuseColor: atoms.model[index].color } ]
  }
}
```

###### **py_createQmlObject**

A quick-and-dirty solution to create a list of atoms using `instancing` and `Qt.createQmlObject`. It is much faster compared to `Repeater3D` with relatively fast update for up to 1000-2000 of atoms. However, it requires more detailed analysis. One idea is to pass a reference to `InstanceList` to Python and recreate that list in Python when needed, instead of doing it in QML.
```
Model {
  id: atoms
  instancing: InstanceList {
    id: atomsList
    instances: createAtomsList()
  }
  source: "#Sphere"
  materials: [ DefaultMaterial {} ]
}

function createAtomsList() {
  let atoms = []
  for (const atom of proxy.atomsModel) {
    const instance = Qt.createQmlObject('import QtQuick3D
                                         InstanceListEntry {}',
                                         atomsList)
    instance.position = Qt.vector3d(atom.x,
                                    atom.y,
                                    atom.z)
    instance.scale = Qt.vector3d(atom.diameter,
                                 atom.diameter,
                                 atom.diameter)
    instance.color = atom.color
    atoms.push(instance)
  }
  return atoms
}
```

#### Without logic in Python

###### **qml_RandomInstancing**

An example using `RandomInstancing` type to generate a large number of random instances without calling the Python backend. Thus, this example should also work with the [`qml`](https://doc.qt.io/qt-6/qtquick-qml-runtime.html) runtime tool without Python at all. This is the fastest example. It works fine for up to 10000-20000 of atoms.
```
Model {
  instancing: RandomInstancing {
    instanceCount: atomsCount
    position: InstanceRange {
      from: Qt.vector3d(0, 0, 0)
      to: Qt.vector3d(cellLengthA, cellLengthB, cellLengthC)
    }
    rotation: InstanceRange {
        from: Qt.vector3d(0, 0, 0)
        to: Qt.vector3d(360, 360, 360)
    }
    scale: InstanceRange {
        from: Qt.vector3d(0.1, 0.1, 0.1)
        to: Qt.vector3d(0.3, 0.3, 0.3)
    }
    color: InstanceRange {
      from: Qt.rgba(0, 0, 0, 1)
      to: Qt.rgba(1, 1, 1, 1)
    }
  }
  source: "#Sphere"
  materials: [ DefaultMaterial {} ]
}
```

## Links

* Examples: https://doc.qt.io/qt-6/quick3d-examples.html
* Picking example: https://doc.qt.io/qt-6/qtquick3d-picking-main-qml.html
* QtQuick3D instanced rendering: https://www.qt.io/blog/qtquick3d-instanced-rendering
