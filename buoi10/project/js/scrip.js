function loadProductDetail(id) {
    fetch(`ajax/product_detail.php?id=${id}`)
        .then(res => res.text())
        .then(data => document.getElementById('product-detail').innerHTML = data);
}

function addToCart(id) {
    fetch('ajax/cart.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: `id=${id}`
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            document.getElementById('cart-count').innerText = `Giỏ: ${data.cartCount}`;
        }
    });
}

function loadReviews(productId) {
    fetch(`ajax/reviews.php?id=${productId}`)
        .then(res => res.text())
        .then(data => document.getElementById('reviews').innerHTML = data);
}

function loadBrands() {
    const category = document.getElementById('category').value;
    fetch(`ajax/brands_xml.php?category=${category}`)
        .then(res => res.text())
        .then(data => document.getElementById('brands').innerHTML = data);
}

function liveSearch() {
    const keyword = document.getElementById('search').value;
    fetch(`ajax/search.php?q=${keyword}`)
        .then(res => res.text())
        .then(data => document.getElementById('search-result').innerHTML = data);
}

function submitPoll() {
    const vote = document.querySelector('input[name="vote"]:checked');
    if (!vote) return;

    fetch('ajax/vote.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: `vote=${vote.value}`
    })
    .then(res => res.text())
    .then(data => document.getElementById('poll-result').innerHTML = data);
}