const toast = swal.mixin({
    toast: true,
    position: 'top-end',
    showConfirmButton: false,
    timer: 3000
});

document.onkeyup = function (data) {
    if (data.which == 27) {
        $.post('http://zrp_vehsealer/close');
    }
};

function onClickCarBtn(id) {
    swal({
        title: 'Você realmente quer comprar esse carro?',
        text: "Após a compra o carro não será reembolsado.",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#0CC27E',
        cancelButtonColor: '#FF586B',
        confirmButtonText: 'Comprar',
        cancelButtonText: "Cancelar"
    }).then(function (result) {
        if (result.value) {
            $.post('http://zrp_vehsealer/buy', JSON.stringify({model: id})).done(function (data) {
                if (data === 'ok') {
                    swal(
                        'Compra efetuada com sucesso!',
                        'O carro logo será entregue em sua garagem!',
                        'success'
                    );
                } else {
                    swal(
                        'Falha ao comprar!',
                        data,
                        'error'
                    );
                }
            });
        }
    }).catch(swal.noop);
}

function onClickSaleCarBtn(id) {
    console.log(id);
    swal({
        title: 'Você realmente quer comprar esse carro?',
        text: "Após a compra o carro não será reembolsado.",
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#0CC27E',
        cancelButtonColor: '#FF586B',
        confirmButtonText: 'Comprar',
        cancelButtonText: "Cancelar"
    }).then(function (result) {
        if (result.value) {
            let array = id.split("|");
            $.post('http://zrp_vehsealer/sale_buy', JSON.stringify({model: array[1], user_id: array[0]})).done(function (data) {
                if (data === 'ok') {
                    swal(
                        'Compra efetuada com sucesso!',
                        'O carro logo será entregue em sua garagem!',
                        'success'
                    );
                } else {
                    swal(
                        'Falha ao comprar!',
                        data,
                        'error'
                    );
                }
            });
        }
    }).catch(swal.noop);
}

function onClickEditSaleCarBtn(id) {
    $.post('http://zrp_vehsealer/getSaleVehicle', JSON.stringify({model: id})).done(function (data) {
        swal({
            title: 'Editar anuncio',
            showCancelButton: true,
            confirmButtonText: 'Salvar',
            cancelButtonText: "Cancelar",
            confirmButtonColor: '#0CC27E',
            cancelButtonColor: '#FF586B',
            html: `
             <input placeholder = "Preco" value = "${data.price}" id = "input-price" class="swal2-input">
             <input maxlength = "131" value = "${data.description}" placeholder = "Descricao" id = "input-desc" class="swal2-input">
             <button id = "${id}" class="remove-ad btn btn-block btn-danger">Retirar anuncio</button>`,
            preConfirm: function () {
                return new Promise(function (resolve) {
                    resolve([
                        $('#input-price').val(),
                        $('#input-desc').val()
                    ])
                })
            },
            onOpen: function (Swal) {
                $(Swal).find(".remove-ad").click(function () {
                    swal({
                        title: 'Você realmente quer retirar o anuncio?',
                        type: 'question',
                        showCancelButton: true,
                        confirmButtonColor: '#0CC27E',
                        cancelButtonColor: '#FF586B',
                        confirmButtonText: 'Retirar anuncio',
                        cancelButtonText: "Cancelar"
                    }).then(function (result) {
                        if (result.value) {
                            $.post('http://zrp_vehsealer/removeSaleVehicle', JSON.stringify({model: id})).done(function (data) {
                                if (data[0] === 'ok') {
                                    swal({
                                        toast: true,
                                        position: 'top-end',
                                        showConfirmButton: false,
                                        timer: 3000,
                                        type: 'success',
                                        title: 'Anuncio retirado!'
                                    });
                                    let list = $("#car-list");
                                    list.empty();
                                    for (let i = 0; i < data[1].length; i++) {
                                        list.append(`
                                            <div class = "col-6">
                                                <div class = "used-car">
                                                    <div class = "used-car-container">
                                                        <img class = "car-img" src = "${data[1][i].image}">
                                                        <div class = "car-container">
                                                            <p>${data[1][i].name}</p>
                                                            <p class = "price">R$: ${data[1][i].price}</p>
                                                            <button onclick = "${data[1][i].owner_id ? "onClickSaleCarBtn(this.id)" : "onClickEditSaleCarBtn(this.id)"}" id = "${data[1][i].owner_id ? data[1][i].owner_id + "|" + data[1][i].model: data[1][i].model}" class="btn car-btn ${data[1][i].owner_id ? "btn-success" : "btn-warning"}">${data[1][i].owner_id ? "Comprar" : "Editar"}</button>
                                                        </div>
                                                    </div>    
                                                    <div class = "used-car-desc">${data[1][i].description}</div>
                                                </div>
                                            </div>`);
                                    }
                                } else {
                                    swal(
                                        'Falha ao retirar anuncio!',
                                        data,
                                        'error'
                                    );
                                }
                            });
                        }
                    }).catch(swal.noop);
                });
            }
        }).then(function (result) {
            console.log("here");
            let price = parseInt(result.value[0]);
            let desc = result.value[1];
            if (price >= 1 && price < 100000000) {
                if (desc === "") {
                    swal({
                        toast: true,
                        position: 'top-end',
                        showConfirmButton: false,
                        timer: 3000,
                        type: 'error',
                        title: 'Descricao invalida'
                    });
                } else {
                    $.post('http://zrp_vehsealer/editSaleVehicle', JSON.stringify({
                        model: id,
                        price: price,
                        description: desc
                    })).done(function (data) {
                        if (data[0] === 'ok') {
                            swal({
                                toast: true,
                                position: 'top-end',
                                showConfirmButton: false,
                                timer: 3000,
                                type: 'success',
                                title: 'Anuncio editado!'
                            });
                            let list = $("#car-list");
                            list.empty();
                            for (let i = 0; i < data[1].length; i++) {
                                list.append(`
                                    <div class = "col-6">
                                        <div class = "used-car">
                                            <div class = "used-car-container">
                                                <img class = "car-img" src = "${data[1][i].image}">
                                                <div class = "car-container">
                                                    <p>${data[1][i].name}</p>
                                                    <p class = "price">R$: ${data[1][i].price}</p>
                                                    <button onclick = "${data[1][i].owner_id ? "onClickSaleCarBtn(this.id)" : "onClickEditSaleCarBtn(this.id)"}" id = "${data[1][i].owner_id ? data[1][i].owner_id + "|" + data[1][i].model: data[1][i].model}" class="btn car-btn ${data[1][i].owner_id ? "btn-success" : "btn-warning"}">${data[1][i].owner_id ? "Comprar" : "Editar"}</button>
                                                </div>
                                            </div>    
                                            <div class = "used-car-desc">${data[1][i].description}</div>
                                        </div>
                                    </div>`);
                            }
                        } else {
                            swal({
                                toast: true,
                                position: 'top-end',
                                showConfirmButton: false,
                                timer: 3000,
                                type: 'error',
                                title: data
                            });
                        }
                    });
                }
            } else {
                swal({
                    toast: true,
                    position: 'top-end',
                    showConfirmButton: false,
                    timer: 3000,
                    type: 'error',
                    title: 'Preco invalido'
                });
            }
        });
    });
}

function onClickSellBtn(id) {
    swal({
        title: 'Criar anuncio',
        showCancelButton: true,
        confirmButtonText: 'Criar!',
        cancelButtonText: "Cancelar",
        confirmButtonColor: '#0CC27E',
        cancelButtonColor: '#FF586B',
        html: `
             <input placeholder = "Preco" id = "input-price" class="swal2-input">
             <input maxlength = "131" placeholder = "Descricao" id = "input-desc" class="swal2-input">`,
        preConfirm: function () {
            return new Promise(function (resolve) {
                resolve([
                    $('#input-price').val(),
                    $('#input-desc').val()
                ])
            })
        }
    }).then(function (result) {
        let price = parseInt(result.value[0]);
        let desc = result.value[1];
        if (price >= 1 && price < 100000000) {
            if (desc === "") {
                swal({
                    toast: true,
                    position: 'top-end',
                    showConfirmButton: false,
                    timer: 3000,
                    type: 'error',
                    title: 'Descricao invalida'
                });
            } else {
                $.post('http://zrp_vehsealer/sell', JSON.stringify({
                    model: id,
                    price: price,
                    description: desc
                })).done(function (data) {
                    if (data[0] === 'ok') {
                        swal({
                            toast: true,
                            position: 'top-end',
                            showConfirmButton: false,
                            timer: 3000,
                            type: 'success',
                            title: 'Anuncio criado com sucesso!'
                        });
                        let list = $("#car-list");
                        list.empty();
                        for (let i = 0; i < data[1].length; i++) {
                            list.append(`
                            <div class = "col-6">
                                <div class = "car">
                                    <img class = "car-img" src = "${data[1][i].image}">
                                    <div class = "car-container">
                                        <p>${data[1][i].name}</p>             
                                        <button onclick = "onClickSellBtn(this.id)" id = "${data[1][i].model}" class="btn car-btn btn-warning">Vender</button>
                                    </div>
                                </div>
                            </div>`);
                        }
                    } else {
                        swal({
                            toast: true,
                            position: 'top-end',
                            showConfirmButton: false,
                            timer: 3000,
                            type: 'error',
                            title: data
                        });
                    }
                });
            }
        } else {
            swal({
                toast: true,
                position: 'top-end',
                showConfirmButton: false,
                timer: 3000,
                type: 'error',
                title: 'Preco invalido'
            });
        }
    }).catch(swal.noop);


}