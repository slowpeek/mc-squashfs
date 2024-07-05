# This script expects raw output of `unsquashfs -d '' -lls ..`. The first line
# is for the root dir, thats why there is NR>1 condition.

NR>1 {
    o = 0

    # Special case: block/character device with "size" column matching /major, +minor/
    if (substr($3, length($3)) == ",") {
        # Make it "major,minor"
        $3 = $3 $4

        # Step over the "minor" field in the following
        o = 1
    }

    # Split "user/group"
    split($2, owner, "/")

    # Split "YYYY-MM-DD"
    split($(4+o), date, "-")

    # Slash in "user/group"
    i = index($0, "/")
    # Leading slash in the path
    i += index(substr($0, i+1), "/")

    # The path part
    s = substr($0, i)

    if (substr($0, 1, 1) == "l") {
        s1=s
        if (gsub("->", "", s1) > 1) {
            # Ambiguity: either the link or its target contains q(->) in
            # addition to the link/target delimiter
            next
        }
    } else if (index(s, "->")) {
        # Ambiguity: not a symlink, but there is q(->)
        next
    }

    print $1, 1, owner[1], owner[2], $3, date[2] "-" date[3] "-" date[1], $(5+o), s
}
