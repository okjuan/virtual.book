document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('post-order-controls');
    form.addEventListener('change', function() {
        const selectedOption = document.querySelector('input[name="option"]:checked').value;
        sortPosts(selectedOption);
    });

    function getDateFromElement(element, dateType) {
        let dateElement = element.querySelector(`time[itemprop="${dateType}"]`);
        if (dateElement === null) {
            if (dateType === "dateModified") {
                // fallback to published date when modified date is not defined
                dateElement = element.querySelector(`time[itemprop="datePublished"]`);
            } else if (dateType === "datePublished") {
                throw new Error(`'datePublished' prop not found for element ${element}. It should always be defined`);
            } else {
                throw new Error(`Unexpected dateType: '${dateType}'`);
            }
        }
        return new Date(dateElement.getAttribute('datetime'));
    }

    function sortPosts(sortKey) {
        const postList = document.getElementById('post-list');
        const posts = Array.from(postList.querySelectorAll('li'));
        posts.sort((a, b) => {
            const dateA = getDateFromElement(a, sortKey);
            const dateB = getDateFromElement(b, sortKey);
            return dateB - dateA;
        });

        // Clear the post list and append sorted posts
        postList.innerHTML = '';
        posts.forEach(post => postList.appendChild(post));
    }
});