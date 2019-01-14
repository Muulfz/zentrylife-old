let cars = undefined;
let mainClass = undefined;

document.onkeydown = function (data) {
    if (data.which === 27) {
        $.post('http://zrp_interface/close');
    }
};

$(document).ready(function () {
    $.post("http://zrp_interface/veh_sealer/onLoad", JSON.stringify({})).done(function (data) {
        cars = data.cars;
        for (let i = 0; i < data.classes.length; i++) {
            $("#class-list").append(`
                <div onclick = "appendClassToCarList(this.id)" id = "${data.classes[i]}" class = "class">${data.classes[i]}</div>
            `);
        }
        $("#class-list").append(`
           <div onclick = "onClickSaleClassBtn()" id = "Usados" class = "class">Usados</div>
        `);
        mainClass = data.classes[0];
        //setTimeout(appendClassToCarList(mainClass), 1000)
    });
});

function carsFrameLoaded() {
    appendClassToCarList(mainClass);
}


function appendClassToCarList(id) {
    $("#class-rest").text(id);
    let list = $("#cars").contents().find("#car-list");
    list.empty();
    for (let i = 0; i < cars.length; i++) {
        if (cars[i].class === id) {
            list.append(`
                <div class = "col-6">
                    <div class = "car">
                        <img class = "car-img" src = "${cars[i].image}">
                        <div class = "car-container">
                            <p>${cars[i].name}</p>
                            <p class = "price">R$: ${cars[i].price}</p>
                            <button onclick = "onClickCarBtn(this.id)" id = "${cars[i].model}" class="btn car-btn btn-success">Comprar</button>
                        </div>
                    </div>
                </div>`);
        }
    }
}

function onClickSaleClassBtn() {
    $.post('http://zrp_interface/veh_sealer/getSaleVehicles', JSON.stringify({})).done(function (data) {
        $("#class-rest").text("Usados");
        let list = $("#cars").contents().find("#car-list");
        list.empty();
        for (let i = 0; i < data.length; i++) {
            list.append(`
            <div class = "col-6">
                    <div class = "used-car">
                        <div class = "used-car-container">
                            <img class = "car-img" src = "${data[i].image}">
                            <div class = "car-container">
                                <p>${data[i].name}</p>
                                <p class = "price">R$: ${data[i].price}</p>
                                <button onclick = "${data[i].owner_id ? "onClickSaleCarBtn(this.id)" : "onClickEditSaleCarBtn(this.id)"}" id = "${data[i].owner_id ? data[i].owner_id + "|" + data[i].model: data[i].model}" class="btn car-btn ${data[i].owner_id ? "btn-success" : "btn-warning"}">${data[i].owner_id ? "Comprar" : "Editar"}</button>
                            </div>
                        </div>    
                        <div class = "used-car-desc">${data[i].description}</div>
                    </div>
                </div>`);
        }
    });
}

function onClickSellClassBtn() {
    $.post('http://zrp_interface/veh_sealer/getVehicles', JSON.stringify({})).done(function (data) {
        $("#class-rest").text("Vender");
        let list = $("#cars").contents().find("#car-list");
        list.empty();
        for (let i = 0; i < data.length; i++) {
            list.append(`
            <div class = "col-6">
                <div class = "car">
                    <img class = "car-img" src = "${data[i].image}">
                    <div class = "car-container">
                        <p>${data[i].name}</p>             
                        <button onclick = "onClickSellBtn(this.id)" id = "${data[i].model}" class="btn car-btn btn-warning">Vender</button>
                    </div>
                </div>
            </div>`);
        }
    });
}
