function onClickCarBtn(id) {
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
}