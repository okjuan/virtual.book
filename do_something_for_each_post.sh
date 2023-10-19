set -e

category_name=$1

posts=$(find "$category_name/_posts" -type f -name "*.md")
for post in $posts
do
    post_copy="$post"_COPY
    cp $post $post_copy

    # prepend $category_name to the tags
    cat $post_copy | sed s"/tags: /tags: $category_name /" > $post

    cp $post $post_copy

    # replace 'category: ' line with ''
    cat $post_copy | sed s"/category:.*$//" > $post

    rm $post_copy
done
