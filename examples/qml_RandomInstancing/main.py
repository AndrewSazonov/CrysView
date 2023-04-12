import sys
from pathlib import Path

from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtGui import QSurfaceFormat
from PySide6.QtQuick3D import QQuick3D


if __name__ == '__main__':
    app = QApplication(sys.argv)
    QSurfaceFormat.setDefaultFormat(QQuick3D.idealSurfaceFormat(4))
    engine = QQmlApplicationEngine()
    engine.load(Path(__file__).parent.absolute() / "main.qml")
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
