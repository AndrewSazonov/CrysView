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

#### With Python as a backend

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

Quick-and-dirty solution of creating list of atoms using `instancing` and `Qt.createQmlObject`. It works much faster compared to `Repeater3D` with relatively quick update for up to 1000-2000 of atoms. However, it needs more detailed analysis.
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
