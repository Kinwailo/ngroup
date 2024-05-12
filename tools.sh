echo 1 flutter build windows
echo 2 flutter build apk
echo 3 flutter build appbundle
echo 4 flutter build web
echo 5 dart run icons_launcher:create
echo 6 dart run build_runner build
echo 7 dart run package_rename_plus

read opt
case $opt in
    1) flutter build windows;;
    2) flutter build apk;;
    3) flutter build appbundle;;
    4) flutter build web;;
    5) dart run icons_launcher:create;;
    6) dart run build_runner build;;
    7) dart run package_rename_plus;;
esac
