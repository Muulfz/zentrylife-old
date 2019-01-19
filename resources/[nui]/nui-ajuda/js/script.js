$(document).ready(function() {

    const cdn = "http://brasilplayaction.com.br/cdn/help/";

    const owlConfig = {
        autoWidth:true,
        nav: true,
        // margin: 50,
        navText : [
            "<i class='fa fa-chevron-left'></i>", "<i class='fa fa-chevron-right'></i>"
        ],
    };

    let topics = [];
    /**
     * FiveM event listener.
     */
    window.addEventListener('message', function(event) {
        let data = event.data;

        switch(data.action) {
            case 'openNui':
                topics = JSON.parse(data.topics);
                showMainPage();
                break;
            case 'hideNui':
                hideHelpPanel();
                break;
        }
    });
    /**
     * Funções
     */
    let showMainPage = () => {
        mountCarousel();
        setTimeout(() => {
            $('.bpa-mainpage').show();
            $('.bpa-help').show();
            $('body').show();
        }, 50);
    };

    let mountCarousel = () => {
        $('.bpa-topics').html(`
            <div class='owl-carousel'>
                ${topics.map((topic, k) => (`
                    <div class="topic-container" style='${k < topics.length - 1 ? 'padding-right: 50px;' : ''}'>
                        <div id="topic_${k}" class="topic-w" data-key="${k}" data-description="${topic.title}" data-icon="${topic.icon}">
                            <div class="topic-img" style="background-image:url(${cdn + topic.icon}.png)"></div>
                        </div>
                    </div>
                `)).join('')}
            </div>
        `);
        $(".owl-carousel").owlCarousel(owlConfig);
    }

    let showTopicPage = (topic) => {
        $('.bpa-mainpage').hide();
        $('.topic-title').html(topic.title);
        mountTopicView(topic);
        $('.bpa-topicpage').show();
    }

    let mountTopicView = (topic) => {
        $('.bpa-scroll').html(`
            ${topic.video ? `
                <div class="bpa-video">
                    <div class="embed-responsive embed-responsive-4by3">
                        <iframe class="embed-responsive-item" src="https://www.youtube.com/embed/${topic.video}?rel=0"></iframe>
                    </div>
                </div>
            ` : ''}
            ${topic.html}
        `)
        $('.bpa-scroll').slimScroll({
            height: '480px',
            position: 'right',
            color: 'rgb(169, 69, 106)',
            alwaysVisible: true
        });
    };

    let hideTopicView = () => {
        $('.bpa-topicpage').hide();
        $('.topic-title').html('');
        $('.bpa-scroll').html('');
        $(".bpa-scroll").slimScroll({destroy: true});
        $('.bpa-mainpage').show();
    }

    let hideHelpPanel = () => {
        $('body').hide();
        hideMainPage();
    }

    let hideMainPage = () => {
        $('.bpa-mainpage').hide();
    }
    /**
     * Catches the hover on topic wrapper
     */
    $('body').on('mouseenter', '.topic-w', function() {
        $(`#${this.id} .topic-img`).css("background-image", `url(${cdn + $(this).attr('data-icon')}-hover.png)`);
    })

    $('body').on('mouseleave', '.topic-w', function() {
        $(`#${this.id} .topic-img`).css("background-image", `url(${cdn + $(this).attr('data-icon')}.png)`);
    });

    $('body').on('click', '.topic-w', function(){
        hideMainPage();
        showTopicPage(topics[$(this).attr('data-key')]);
    });

    $('body').on('click', '.btn-back', function() {
        hideTopicView();

    });

    $('body').on('click', '.btn-close', function(){
        hideHelpPanel();
        $.post('http://nui-ajuda/close');
    });
    /**
     * keyevents.
     */
    document.onkeyup = function (data) {
        if (data.which == 27) {
            hideHelpPanel();
            $.post('http://nui-ajuda/close');
        }
    };
});