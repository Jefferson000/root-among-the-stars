#!/usr/bin/env python3
import os
from functools import lru_cache

# Root is the current working directory
ROOT = os.getcwd()

# Extensions to include (case-insensitive)
EXTS = {
    # Godot scripts & scenes/resources
    ".gd", ".scene", ".tscn", ".scn", ".res", ".tres",
    # Images
    ".png", ".jpg", ".jpeg", ".gif", ".bmp", ".tga", ".webp",
    # Audio
    ".wav", ".ogg", ".mp3", ".flac",
    # Video
    ".mp4", ".avi", ".mkv", ".webm",
}

# Icons
ICON_ROOT_FOLDER = "📂"
ICON_INTERMEDIATE_FOLDER = "📁"
ICON_LEAF_FOLDER = "🔹"

def file_icon(name: str) -> str:
    ext = os.path.splitext(name)[1].lower()
    if ext == ".gd":
        return "📝"   # script
    if ext in {".scene", ".tscn", ".scn"}:
        return "🎬"   # scene
    if ext in {".res", ".tres"}:
        return "📦"   # resource
    if ext in {".png", ".jpg", ".jpeg", ".gif", ".bmp", ".tga", ".webp"}:
        return "🖼️"  # image
    if ext in {".wav", ".ogg", ".mp3", ".flac"}:
        return "🎵"   # audio
    if ext in {".mp4", ".avi", ".mkv", ".webm"}:
        return "🎞️"  # video
    return "📄"       # fallback

def matches(filename: str) -> bool:
    return os.path.splitext(filename)[1].lower() in EXTS

@lru_cache(maxsize=None)
def dir_has_any_matches(path: str) -> bool:
    """True if this directory or any subdirectory contains a matching file."""
    for _, _, files in os.walk(path):
        for f in files:
            if matches(f):
                return True
    return False

@lru_cache(maxsize=None)
def has_child_dirs_with_matches(path: str) -> bool:
    """True if this directory has any *immediate* subdirectory that (recursively) contains a match."""
    try:
        with os.scandir(path) as it:
            for e in it:
                if e.is_dir(follow_symlinks=False) and dir_has_any_matches(e.path):
                    return True
    except PermissionError:
        pass
    return False

def iter_children(path: str):
    """
    Yield filtered children as tuples:
      - ('dir', name, full_path, is_leaf_dir)
      - ('file', name, full_path)
    Only shows dirs that (recursively) contain matches and files that match.
    """
    try:
        dirs, files = [], []
        with os.scandir(path) as it:
            for entry in it:
                if entry.is_dir(follow_symlinks=False):
                    if dir_has_any_matches(entry.path):
                        is_leaf = not has_child_dirs_with_matches(entry.path)
                        dirs.append(("dir", entry.name, entry.path, is_leaf))
                elif entry.is_file(follow_symlinks=False) and matches(entry.name):
                    files.append(("file", entry.name, entry.path))
        # sort case-insensitively
        dirs.sort(key=lambda t: t[1].lower())
        files.sort(key=lambda t: t[1].lower())
        for d in dirs:
            yield d
        for f in files:
            yield f
    except PermissionError:
        return

def print_tree(path: str, prefix: str = "", is_root: bool = False):
    if is_root:
        print(f"{ICON_ROOT_FOLDER} .")
    children = list(iter_children(path))
    for idx, child in enumerate(children):
        last = (idx == len(children) - 1)
        branch = "└──" if last else "├──"

        if child[0] == "dir":
            _, name, full, is_leaf = child
            folder_icon = ICON_LEAF_FOLDER if is_leaf else ICON_INTERMEDIATE_FOLDER
            print(f"{prefix}{branch} {folder_icon} {name}/")
            next_prefix = f"{prefix}{'    ' if last else '│   '}"
            print_tree(full, next_prefix, False)
        else:
            _, name, _ = child
            print(f"{prefix}{branch} {file_icon(name)} {name}")

def main():
    if not dir_has_any_matches(ROOT):
        print("No matching files found.")
        return
    print_tree(ROOT, "", True)

if __name__ == "__main__":
    main()
