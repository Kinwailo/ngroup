echo 1 flutter build windows --no-tree-shake-icons
echo 2 flutter build apk --no-tree-shake-icons
echo 3 flutter pub run icons_launcher:create
echo 4 flutter pub run build_runner build
echo 5 dart run package_rename_plus

read opt
case $opt in
    1) flutter build windows;;
    2) flutter build apk;;
    3) flutter pub run icons_launcher:create;;
    4) flutter pub run build_runner build;;
    5) dart run package_rename_plus;;
esac
