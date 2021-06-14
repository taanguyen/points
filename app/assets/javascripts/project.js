$(() => {
  $("#bulk_delete").click(() => {
    let stories_ids = []
    $("input[name='stories[]']:checked").each((_, checkbox) => {
      stories_ids.push($(checkbox).val())
    })

    let token = $("meta[name='csrf-token']").attr("content")
    $.ajaxSetup({
      beforeSend: function (xhr) {
        xhr.setRequestHeader("X-CSRF-Token", token);
      }
    });

    $.ajax({
      url: "/stories/bulk_destroy",
      data: {ids: stories_ids},
      type: "POST",
      success: () => {
        $(stories_ids).each((_, id) => {
          console.log(id)
          $("#story_" + id).remove();
        })
      },
      error: (result) => {
        console.log("There was an error destroying the stories")
      }
    })
  })
})

function debounce(func, timeout = 300) {                                                
	let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => { func.apply(this, args); }, timeout);
  };
};

const filterStories = debounce(() => { $("#story_search").submit() });
