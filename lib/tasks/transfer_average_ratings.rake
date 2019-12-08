# Ratingのレコード数を削減するために、各プロポーザルごとの平均点の数字だけをProposal側にコピーするスクリプト
# まず、 bin/rails transfer_average_ratings[2015] とかそんな感じで平均点のコピーを行って、次に drop_ratings でRatingのレコードを削除する。

desc 'Transfer ratings data to proposals.averate_rating'
task :transfer_average_ratings, [:event_slug] => :environment do |t, args|
  event = Event.find_by! slug: args[:event_slug]
  event.proposals.where(average_rating: nil).where(Rating.where('proposal_id = proposals.id').arel.exists).each do |proposal|
    p proposal.id => proposal.average_rating
    proposal.update_column :average_rating, proposal.average_rating
  end
end

desc 'Delete ratings records that are already transferred to proposals.averate_rating'
task :drop_ratings, [:event_slug] => :environment do |t, args|
  event = Event.find_by! slug: args[:event_slug]
  event.ratings.each do |rating|
    unless rating.proposal[:average_rating]
      puts "Rating##{rating.id} hasn't been transferred yet."
      next
    end

    p "Destroying Rating##{rating.id}..."
    rating.destroy
  end
end
