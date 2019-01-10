$(document).ready(function () {
    $('#list').click(function (event) {
        event.preventDefault();
        $('#products .item').addClass('list-group-item');
    });
    $('#grid').click(function (event) {
        event.preventDefault();
        $('#products .item').removeClass('list-group-item');
        $('#products .item').addClass('grid-group-item');
    });

    $('.car-buy-btn').on('click', function () {
        swal({
            title: 'Você realmente quer comprar esse carro?',
            text: "Após a compra o carro não será reembolsado.",
            type: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#0CC27E',
            cancelButtonColor: '#FF586B',
            confirmButtonText: 'Comprar',
            cancelButtonText: "Cancelar"
        }).then(function (isConfirm) {
            if (isConfirm) {
                $.post('http://zrp_vehsealer/buy', JSON.stringify({model: $(this).attr('id')})).done(function (data) {
                    if (data !== 'ok') {
                        swal(
                            'Compra efetuada com sucesso!',
                            'O carro logo será entregue em sua garagem!',
                            'success'
                        );
                    } else {
                        swal(
                            'Falha ao comprar!',
                            'O carro logo será entregue em sua garagem!',
                            'error'
                        );
                    }
                });
            }
        }).catch(swal.noop);
    });

    window.addEventListener('message', function (event) {
        let data = event.data;
        console.log(JSON.stringify(data));
        if (data.func === 'create') {
            for (let i = 0; i < data.cars.length; i++) {
                //console.log(data.cars[i].model);
                $("#products").append(`
                <div class="item col-xs-4 col-lg-4">
                    <div class="thumbnail card">
                        <div class="img-event">
                            <img class="group list-group-image img-fluid" src="${data.cars[i].image}" alt="" />
                        </div>
                        <div class="caption card-body">
                            <h4 class="group card-title inner list-group-item-heading">
                            </h4>
                            <p class="group inner list-group-item-text">
                               ${data.cars[i].description}</p>
                            <div class="row">
                                <div class="col-xs-12 col-md-6">
                                    <p class="lead">
                                        R$ ${data.cars[i].price}</p>
                                </div>
                                <div class="col-xs-12 col-md-6">
                                    <button class="btn btn-success car-buy-btn" id="${data.cars[i].model}">Compre Agora!</button>
                                </div>
                            </div>
                        </div>
                    </div>  
                </div>`
                );
            }
        }else{
            $("body").css("display",data.show? "block":"none");
        }
    });

});

document.onkeyup = function (data) {
    if (data.which == 27 ) {
        $.post('http://zrp_vehsealer/close');
    }
};

$(window).load(function () {
    $('.flexslider').flexslider({
        animation: "slide",
        animationLoop: false,
        itemWidth: 210,
        itemMargin: 5
    });
});







