import sys, os
import timeit
import random
import numpy as np
import scipy as sc
import lmfit
import iminuit

from PySide6.QtCore import QObject, Signal, Slot, Property
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtGui import QSurfaceFormat, QColor, QVector3D
from PySide6.QtQuick3D import QQuick3D, QQuick3DInstancing


class Proxy(QObject):
    atomsModelChanged = Signal()
    atomsCountChanged = Signal()

    atomInstancesChanged = Signal()

    def __init__(self, parent=None):
        super(Proxy, self).__init__(parent)
        self._atomsCount = 2
        self._atomsModel = []
        self.createAtomsModel()

        self._atomInstances = None

    @Property('QVariant', notify=atomInstancesChanged)
    def atomInstances(self):
        return self._atomInstances

    @atomInstances.setter
    def atomInstances(self, new_value):
        if self._atomInstances == new_value:
            return
        print('+++ self._atomInstances (before)', self._atomInstances)
        self._atomInstances = new_value
        print('+++ self._atomInstances (after)', self._atomInstances)
        print('    1', self._atomInstances.childItems())
        instance0 = self._atomInstances.childItems()[0]

        print('   refs', id(instance0), id(self._atomInstances.childItems()[0]))
        self._atomInstances.childItems().append(instance0)
        print('    1', self._atomInstances.childItems())
        #print('    2', self._atomInstances.children())
        print('    3', self._atomInstances.instanceColor(0), self._atomInstances.instanceColor(1))
        #self._atomInstances.append({})
        self.atomInstancesChanged.emit()



    @Property(int, notify=atomsCountChanged)
    def atomsCount(self):
        return self._atomsCount

    @atomsCount.setter
    def atomsCount(self, new_value):
        if self._atomsCount == new_value:
            return
        self._atomsCount = new_value
        self.atomsCountChanged.emit()

    @Property('QVariant', notify=atomsModelChanged)
    def atomsModel(self):
        return self._atomsModel

    @Slot()
    def createAtomsModel(self):
        self._atomsModel = [{'x': random.random(),
                             'y': random.random(),
                             'z': random.random(),
                             'diameter': 2 * random.uniform(0.05, 0.15),
                             'color': QColor(int(random.random() * 255),
                                             int(random.random() * 255),
                                             int(random.random() * 255)).name(),
                             }
                             for _ in range(self._atomsCount)]
        self.atomsModelChanged.emit()


if __name__ == '__main__':
    app = QApplication(sys.argv)
    QSurfaceFormat.setDefaultFormat(QQuick3D.idealSurfaceFormat(4))  # QtQuick3D
    proxy = Proxy()
    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("proxy", proxy)
    engine.load("main.qml")
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
