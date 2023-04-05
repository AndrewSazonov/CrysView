import sys
import random

from PySide6.QtCore import QObject, Signal, Slot, Property
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtGui import QSurfaceFormat, QColor
from PySide6.QtQuick3D import QQuick3D


class Proxy(QObject):
    atomsModelChanged = Signal()
    atomsCountChanged = Signal()

    def __init__(self, parent=None):
        super(Proxy, self).__init__(parent)
        self._atomsCount = 10
        self._atomsModel = []
        self.createAtomsModel()

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
    QSurfaceFormat.setDefaultFormat(QQuick3D.idealSurfaceFormat(4))
    proxy = Proxy()
    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("proxy", proxy)
    engine.load("main.qml")
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
