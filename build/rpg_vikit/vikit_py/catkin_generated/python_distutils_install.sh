#!/bin/sh

if [ -n "$DESTDIR" ] ; then
    case $DESTDIR in
        /*) # ok
            ;;
        *)
            /bin/echo "DESTDIR argument must be absolute... "
            /bin/echo "otherwise python's distutils will bork things."
            exit 1
    esac
fi

echo_and_run() { echo "+ $@" ; "$@" ; }

echo_and_run cd "/home/developer/sc_fastlivo2/src/rpg_vikit/vikit_py"

# ensure that Python install destination exists
echo_and_run mkdir -p "$DESTDIR/home/developer/sc_fastlivo2/install/lib/python3/dist-packages"

# Note that PYTHONPATH is pulled from the environment to support installing
# into one location when some dependencies were installed in another
# location, #123.
echo_and_run /usr/bin/env \
    PYTHONPATH="/home/developer/sc_fastlivo2/install/lib/python3/dist-packages:/home/developer/sc_fastlivo2/build/lib/python3/dist-packages:$PYTHONPATH" \
    CATKIN_BINARY_DIR="/home/developer/sc_fastlivo2/build" \
    "/usr/bin/python3" \
    "/home/developer/sc_fastlivo2/src/rpg_vikit/vikit_py/setup.py" \
     \
    build --build-base "/home/developer/sc_fastlivo2/build/rpg_vikit/vikit_py" \
    install \
    --root="${DESTDIR-/}" \
    --install-layout=deb --prefix="/home/developer/sc_fastlivo2/install" --install-scripts="/home/developer/sc_fastlivo2/install/bin"
