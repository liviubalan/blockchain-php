function getDivError(message) {
    return '<div class="alert alert-danger" role="alert">' + message + '</div>';
}

function getTrThTd(th, td) {
    let tr = '<tr>';
    tr += '<th scope="row">' + th + '</th>';
    tr += '<td>' + td + '</td>';
    tr += '</tr>';

    return tr;
}

function getTrThThTh(th1, th2, th3) {
    let tr = '<tr>';
    tr += '<th scope="row">' + th1 + '</th>';
    tr += '<th scope="row">' + th2 + '</th>';
    tr += '<th scope="row">' + th3 + '</th>';
    tr += '</tr>';

    return tr;
}

function getTrTdTdTd(td1, td2, td3) {
    let tr = '<tr>';
    tr += '<td>' + td1 + '</td>';
    tr += '<td>' + td2 + '</td>';
    tr += '<td>' + td3 + '</td>';
    tr += '</tr>';

    return tr;
}

$(document).ready(function () {
    $("#searchButton").click(function () {
        const searchInput = $("#searchInput").val();

        if (searchInput === '') {
            $("#searchResult").html(getDivError('You have to enter a value for <strong>Search</strong>.'));
            return;
        }

        const searchSelect = $("#searchSelect").val();
        let url = '';
        switch (searchSelect) {
            case 'transaction':
                url = '/transaction/{transactionId}';
                url = url.replace('{transactionId}', searchInput);
                break;
            case 'address':
                url = '/address/{address}';
                url = url.replace('{address}', searchInput);
                break;
            default:
                url = '/block/{blockHash}';
                url = url.replace('{blockHash}', searchInput);
                break;
        }

        $.get(url, function (data) {
            if (
                Object.keys(data).length === 0
                || (searchSelect == 'address' && data.addressTransactions.length == 0)
            ) {
                $("#searchResult").html(getDivError('No results.'));
                return;
            }

            let searchResultHtml = `
            <table class="table table-striped table-bordered">
                <tbody>
            `;

            switch (searchSelect) {
                case 'transaction':
                    searchResultHtml += getTrThTd('Sender', data.transaction.sender);
                    searchResultHtml += getTrThTd('Recipient', data.transaction.recipient);
                    searchResultHtml += getTrThTd('Amount', data.transaction.amount);
                    break;
                case 'address':
                    searchResultHtml += getTrThThTh('Sender', 'Recipient', 'Amount');
                    data.addressTransactions.forEach(address => {
                        searchResultHtml += getTrTdTdTd(
                            address.sender,
                            address.recipient,
                            address.amount
                        );
                    });
                    break;
                default:
                    searchResultHtml += getTrThTd('Block Hash', data.hash);
                    searchResultHtml += getTrThTd('Index', data.index);
                    searchResultHtml += getTrThTd('Time Stamp', data.timestamp);
                    searchResultHtml += getTrThTd('Nonce', data.nonce);
                    searchResultHtml += getTrThTd('Previous Hash', data.previousBlockHash);
                    searchResultHtml += getTrThTd('Number Transactions', data.transactions.length);
                    break;
            }

            searchResultHtml += `
                </tbody>
            </table>
            `;

            $("#searchResult").html(searchResultHtml);
        })
    });
});
