defmodule TicTacToeQuiqupWeb.ErrorView do
  use TicTacToeQuiqupWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.html", _assigns) do
  #   "Internal Server Error"
  # end
  def render("4xx.json", %{error: message}) do
    %{errors: %{details: message}}
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
